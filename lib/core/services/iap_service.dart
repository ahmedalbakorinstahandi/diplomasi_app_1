import 'dart:async';
import 'dart:convert';

import 'package:diplomasi_app/core/functions/print.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';

/// ???? ???? ???????? ????????? ??? Apple In-App Purchase (iOS ???).
/// ?? ????? ?????? ?????? ??? ??? ?????? ?? ??????? ??? ??????.
class IapService {
  final BillingData _billingData = BillingData();
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<void>? _pendingVerification;
  PlanModel? _pendingPlan;
  List<PlanModel> _plansForRestore = [];
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  /// ????? ?????? ????????? ?? ???? ?????????. ????? ?? ???? ????? ??? iOS.
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
          purchase.error ?? Exception('??? ??????'),
        );
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }
      if (purchase.status == PurchaseStatus.canceled) {
        _pendingVerification?.completeError(Exception('?? ????? ??????'));
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        unawaited(_verifyPurchase(purchase));
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

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    PlanModel? plan = _pendingPlan;
    if (plan == null && _plansForRestore.isNotEmpty) {
      final match = _plansForRestore
          .where((p) => p.iosProductId == purchase.productID)
          .toList();
      plan = match.isNotEmpty ? match.first : null;
    }
    if (plan == null || plan.iosProductId == null) {
      _pendingVerification?.completeError(
        Exception('?? ???? ??? ????? ??????'),
      );
      _pendingVerification = null;
      _pendingPlan = null;
      return;
    }

    final receipt = purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    String? transactionId = purchase.purchaseID;
    transactionId ??= _extractTransactionIdFromVerificationData(purchase);

    if (receipt.isEmpty) {
      _pendingVerification?.completeError(Exception('?????? ??????? ?????'));
      _pendingVerification = null;
      _pendingPlan = null;
      return;
    }

    try {
      final response = await _billingData.verifyApplePurchase(
        planId: plan.id,
        productId: productId,
        transactionId: transactionId,
        receipt: receipt,
      );
      if (response.success == true) {
        _pendingVerification?.complete();
      } else {
        _pendingVerification?.completeError(
          Exception(response.message ?? '??? ?????? ?? ??????'),
        );
      }
    } catch (e) {
      _pendingVerification?.completeError(e);
    } finally {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    _pendingVerification = null;
    _pendingPlan = null;
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
        // serverVerificationData ?? ???? base64 ???? JSON.
      }
    }

    return null;
  }

  /// ???? ??? ??? iOS. ????? ??? ???? ?????? ?? ??????.
  Future<void> purchasePlan(PlanModel plan) async {
    if (plan.iosProductId == null || plan.iosProductId!.isEmpty) {
      throw Exception('??? ????? ??? ????? ?????? ??? ???????');
    }
    if (!_isAvailable) {
      throw Exception('?????? ???? ??????? ??? ???? ??????');
    }

    final productId = plan.iosProductId!;
    final productIds = {productId};
    printDebug('starting to query product details');
    final response = await _iap.queryProductDetails(productIds);
    printDebug('response: $response');

    if (response.notFoundIDs.isNotEmpty) {
      printDebug(response.notFoundIDs);
      printDebug(response.error.toString());
      throw Exception(
        '?????? ??? ????? ?? ??????. ???? ?? ????? ?????? ?? App Store Connect '
        '?????? ????? ??????: $productId',
      );
    }

    final productDetails = response.productDetails;
    if (productDetails.isEmpty) {
      throw Exception('?? ??? ?????? ??? ?????? ??????');
    }

    _pendingVerification = Completer<void>();
    _pendingPlan = plan;
    final param = PurchaseParam(productDetails: productDetails.first);
    final success = await _iap.buyNonConsumable(purchaseParam: param);
    if (!success) {
      _pendingPlan = null;
      _pendingVerification = null;
      throw Exception('?? ??? ??? ????? ??????');
    }

    return _pendingVerification!.future;
  }

  /// ??????? ?????????. ??? ????? ????? ????? (???????? ??? ios_product_id) ???? ?? ???? ??????? ??????.
  /// ??????? ??????? ??? purchaseStream ?????? ?? ????? ?????? ??????.
  Future<void> restorePurchases(List<PlanModel> plans) async {
    if (!_isAvailable) {
      throw Exception('?????? ???? ??????? ??? ???? ??????');
    }
    _plansForRestore = plans.where((p) => p.iosProductId != null).toList();
    await _iap.restorePurchases();
    _plansForRestore = [];
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _pendingVerification?.completeError(Exception('?? ????? ??????'));
    _pendingVerification = null;
    _pendingPlan = null;
  }
}