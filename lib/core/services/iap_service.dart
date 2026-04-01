import 'dart:async';
import 'dart:convert';

import 'package:diplomasi_app/core/functions/print.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';

/// Apple IAP service for iOS purchases and restore flow.
/// A purchase is considered successful only after backend verification.
class RestorePurchasesResult {
  final int successCount;
  final int failedCount;
  final bool timedOut;

  const RestorePurchasesResult({
    required this.successCount,
    required this.failedCount,
    required this.timedOut,
  });
}

class IapService {
  final BillingData _billingData = BillingData();
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<void>? _pendingVerification;
  PlanModel? _pendingPlan;
  List<PlanModel> _plansForRestore = [];
  Completer<RestorePurchasesResult>? _pendingRestore;
  Timer? _restoreSettleTimer;
  int _restoreSuccessCount = 0;
  int _restoreFailedCount = 0;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: _onPurchaseError,
    );
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        _pendingVerification?.completeError(
          purchase.error ?? Exception('Purchase failed'),
        );
        if (_pendingRestore != null) {
          _restoreFailedCount++;
          _scheduleRestoreSettle();
        }
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _pendingVerification?.completeError(Exception('Purchase cancelled'));
        if (_pendingRestore != null) {
          _restoreFailedCount++;
          _scheduleRestoreSettle();
        }
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        unawaited(
          _verifyPurchase(purchase).then((ok) {
            if (_pendingRestore != null) {
              if (ok) {
                _restoreSuccessCount++;
              } else {
                _restoreFailedCount++;
              }
              _scheduleRestoreSettle();
            }
          }),
        );
      }
    }
  }

  void _onPurchaseError(dynamic error) {
    _pendingVerification?.completeError(
      error is Exception ? error : Exception(error.toString()),
    );
    _pendingPlan = null;
    _pendingVerification = null;
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    final expectedPurchaseProductId = _pendingPlan?.iosProductId;
    if (expectedPurchaseProductId != null &&
        expectedPurchaseProductId != purchase.productID) {
      // Ignore unrelated queued transactions while waiting for selected plan purchase.
      printDebug(
        'Ignoring purchase event for product ${purchase.productID}; '
        'expected $expectedPurchaseProductId',
      );
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          printDebug('completePurchase failed: $e');
        }
      }
      return false;
    }

    PlanModel? plan = _pendingPlan;

    if (plan == null && _plansForRestore.isNotEmpty) {
      final match = _plansForRestore
          .where((p) => p.iosProductId == purchase.productID)
          .toList();
      plan = match.isNotEmpty ? match.first : null;
    }

    if (plan == null || plan.iosProductId == null) {
      if (_pendingVerification != null && _pendingPlan != null) {
        _pendingVerification?.completeError(
          Exception('No pending plan found for verification'),
        );
        _pendingVerification = null;
        _pendingPlan = null;
      }
      return false;
    }

    final receipt = purchase.verificationData.serverVerificationData;
    final productId = plan.iosProductId!;
    String? transactionId = purchase.purchaseID;
    transactionId ??= _extractTransactionIdFromVerificationData(purchase);

    if (receipt.isEmpty) {
      _pendingVerification?.completeError(Exception('Receipt data is missing'));
      _pendingVerification = null;
      _pendingPlan = null;
      return false;
    }

    var verified = false;
    try {
      final response = await _billingData.verifyApplePurchase(
        planId: plan.id,
        productId: productId,
        transactionId: transactionId,
        receipt: receipt,
      );

      if (response.success == true) {
        verified = true;
        _pendingVerification?.complete();
      } else {
        _pendingVerification?.completeError(
          Exception(response.message ?? 'Backend verification failed'),
        );
      }
    } catch (e) {
      _pendingVerification?.completeError(e);
    } finally {
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          printDebug('completePurchase failed: $e');
        }
      }
    }

    _pendingVerification = null;
    _pendingPlan = null;
    return verified;
  }

  String? _extractTransactionIdFromVerificationData(PurchaseDetails purchase) {
    final candidates = [
      purchase.verificationData.localVerificationData,
      purchase.verificationData.serverVerificationData,
    ];

    for (final raw in candidates) {
      if (raw.trim().isEmpty) continue;

      try {
        final data = jsonDecode(raw);
        if (data is Map<String, dynamic>) {
          final tx = (data['transactionId'] ??
                  data['transaction_id'] ??
                  data['id'] ??
                  '')
              .toString()
              .trim();
          if (tx.isNotEmpty) return tx;
        }
      } catch (_) {
        // serverVerificationData can be base64/JWS and not plain JSON.
      }
    }

    return null;
  }

  /// Starts iOS purchase flow and waits for backend verification result.
  Future<void> purchasePlan(PlanModel plan) async {
    if (plan.iosProductId == null || plan.iosProductId!.isEmpty) {
      throw Exception('This plan is not available for iOS in-app purchase');
    }

    if (!_isAvailable) {
      throw Exception('In-app purchases are currently unavailable');
    }

    final productId = plan.iosProductId!;
    final productIds = {productId};

    printDebug('starting to query product details for: $productId');
    final response = await _iap.queryProductDetails(productIds);
    printDebug('response: $response');
    if (response.productDetails.isNotEmpty) {
      final returnedIds = response.productDetails.map((p) => p.id).join(', ');
      printDebug('returned product ids: $returnedIds');
    }

    if (response.notFoundIDs.isNotEmpty) {
      printDebug(response.notFoundIDs);
      printDebug(response.error.toString());
      throw Exception(
        'Product not found in App Store Connect. Ensure exact ID: $productId',
      );
    }

    final productDetails = response.productDetails;
    if (productDetails.isEmpty) {
      throw Exception('No product details returned from App Store');
    }

    ProductDetails? selectedProduct;
    for (final item in productDetails) {
      if (item.id == productId) {
        selectedProduct = item;
        break;
      }
    }
    if (selectedProduct == null) {
      throw Exception(
        'Requested product not returned by store. Requested: $productId',
      );
    }

    _pendingVerification = Completer<void>();
    _pendingPlan = plan;

    final param = PurchaseParam(productDetails: selectedProduct);
    final success = await _iap.buyNonConsumable(purchaseParam: param);
    if (!success) {
      _pendingPlan = null;
      _pendingVerification = null;
      throw Exception('Unable to start purchase flow');
    }

    return _pendingVerification!.future;
  }

  /// Restores purchases. Matching by iosProductId is done in purchase stream.
  Future<RestorePurchasesResult> restorePurchases(List<PlanModel> plans) async {
    if (!_isAvailable) {
      throw Exception('In-app purchases are currently unavailable');
    }

    _pendingRestore = Completer<RestorePurchasesResult>();
    _restoreSuccessCount = 0;
    _restoreFailedCount = 0;
    _plansForRestore = plans.where((p) => p.iosProductId != null).toList();
    await _iap.restorePurchases();

    final timeoutResult = await Future.any<RestorePurchasesResult>([
      _pendingRestore!.future,
      Future.delayed(
        const Duration(seconds: 10),
        () => RestorePurchasesResult(
          successCount: _restoreSuccessCount,
          failedCount: _restoreFailedCount,
          timedOut: true,
        ),
      ),
    ]);

    _finishRestoreIfNeeded(timeoutResult);
    return timeoutResult;
  }

  void _scheduleRestoreSettle() {
    _restoreSettleTimer?.cancel();
    _restoreSettleTimer = Timer(const Duration(milliseconds: 1200), () {
      _finishRestoreIfNeeded(
        RestorePurchasesResult(
          successCount: _restoreSuccessCount,
          failedCount: _restoreFailedCount,
          timedOut: false,
        ),
      );
    });
  }

  void _finishRestoreIfNeeded(RestorePurchasesResult result) {
    if (_pendingRestore != null && !_pendingRestore!.isCompleted) {
      _pendingRestore!.complete(result);
    }
    _restoreSettleTimer?.cancel();
    _restoreSettleTimer = null;
    _pendingRestore = null;
    _plansForRestore = [];
    _restoreSuccessCount = 0;
    _restoreFailedCount = 0;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _restoreSettleTimer?.cancel();
    _restoreSettleTimer = null;
    if (_pendingRestore != null && !_pendingRestore!.isCompleted) {
      _pendingRestore!.complete(
        const RestorePurchasesResult(
          successCount: 0,
          failedCount: 0,
          timedOut: true,
        ),
      );
    }
    _pendingRestore = null;
    _pendingVerification?.completeError(Exception('IAP service disposed'));
    _pendingVerification = null;
    _pendingPlan = null;
  }
}