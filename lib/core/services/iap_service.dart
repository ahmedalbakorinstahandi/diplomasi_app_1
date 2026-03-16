import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';

/// خدمة شراء واستعادة المشتريات عبر Apple In-App Purchase (iOS فقط).
/// لا تعتبر الشراء ناجحاً إلا بعد التحقق من الإيصال عبر الخادم.
class IapService {
  final BillingData _billingData = BillingData();
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<void>? _pendingVerification;
  PlanModel? _pendingPlan;
  List<PlanModel> _plansForRestore = [];
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  /// تهيئة الخدمة والاشتراك في تدفق المشتريات. استدع من شاشة الخطط عند iOS.
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
        // يمكن إظهار مؤشر انتظار
        continue;
      }
      if (purchase.status == PurchaseStatus.error) {
        _pendingVerification?.completeError(
          purchase.error ?? Exception('فشل الشراء'),
        );
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }
      if (purchase.status == PurchaseStatus.canceled) {
        _pendingVerification?.completeError(Exception('تم إلغاء الشراء'));
        _pendingPlan = null;
        _pendingVerification = null;
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyPurchase(purchase);
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
        Exception('لا توجد خطة معلقة للتحقق'),
      );
      _pendingVerification = null;
      _pendingPlan = null;
      return;
    }
    final receipt = purchase.verificationData.serverVerificationData;
    final productId = purchase.productID;
    final transactionId = purchase.purchaseID ?? '';
    if (receipt.isEmpty || transactionId.isEmpty) {
      _pendingVerification?.completeError(
        Exception('بيانات الإيصال ناقصة'),
      );
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
          Exception(response.message ?? 'فشل التحقق من الخادم'),
        );
      }
    } catch (e) {
      _pendingVerification?.completeError(e);
    }
    _pendingVerification = null;
    _pendingPlan = null;
  }

  /// شراء خطة على iOS. يُرجع عند نجاح التحقق من الخادم.
  Future<void> purchasePlan(PlanModel plan) async {
    if (plan.iosProductId == null || plan.iosProductId!.isEmpty) {
      throw Exception('هذه الخطة غير متاحة للشراء عبر التطبيق');
    }
    if (!_isAvailable) {
      throw Exception('الشراء داخل التطبيق غير متاح حالياً');
    }
    final productId = plan.iosProductId!;
    final productIds = {productId};
    final response = await _iap.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print(response.notFoundIDs);
      print(response.error.toString());
      throw Exception(
        'المنتج غير موجود في المتجر. تأكد من إنشاء المنتج في App Store Connect '
        'بمعرّف مطابق تماماً: $productId',
      );
    }
    final productDetails = response.productDetails;
    if (productDetails.isEmpty) {
      throw Exception('لم يتم العثور على تفاصيل المنتج');
    }
    _pendingVerification = Completer<void>();
    _pendingPlan = plan;
    final param = PurchaseParam(productDetails: productDetails.first);
    final success = await _iap.buyNonConsumable(purchaseParam: param);
    if (!success) {
      _pendingPlan = null;
      _pendingVerification = null;
      throw Exception('لم يتم بدء عملية الشراء');
    }
    return _pendingVerification!.future;
  }

  /// استعادة المشتريات. يجب تمرير قائمة الخطط (المحتوية على ios_product_id) لربط كل منتج مُستعاد بالخطة.
  /// النتائج تُعالَج عبر purchaseStream ويُرسل كل إيصال للخادم للتحقق.
  Future<void> restorePurchases(List<PlanModel> plans) async {
    if (!_isAvailable) {
      throw Exception('الشراء داخل التطبيق غير متاح حالياً');
    }
    _plansForRestore = plans.where((p) => p.iosProductId != null).toList();
    await _iap.restorePurchases();
    _plansForRestore = [];
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _pendingVerification?.completeError(Exception('تم إلغاء الخدمة'));
    _pendingVerification = null;
    _pendingPlan = null;
  }
}
