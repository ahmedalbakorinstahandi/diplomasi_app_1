import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/plans_data.dart';
import 'package:get/get.dart';

abstract class PlansController extends GetxController {
  bool isLoading = false;
  bool isBillingLoading = false;
  bool isActionLoading = false;
  List plans = [];
  Map<String, dynamic>? currentSubscription;
  bool hasPaymentMethod = false;
  bool hasDefaultPaymentMethod = false;
  String? defaultPaymentMethodStatus;
  bool canRetryPayment = false;
  String? retryStatusMessage;
  String retryStatusType = 'none';
  int? actionPlanId;
  int? purchaseFlowPlanId;
  bool isPurchaseFlowInProgress = false;
  List<Map<String, dynamic>> paymentMethods = [];
  int? defaultPaymentMethodId;

  PlansData plansData = PlansData();
  BillingData billingData = BillingData();

  Future<void> getPlans();
  Future<void> loadBillingState();
  Future<void> cancelSubscription();
  Future<void> resumeSubscription();
  Future<void> retryPayment();
  Future<void> purchasePlan(PlanModel plan, {int? paymentMethodId});
  Future<bool> setDefaultPaymentMethod(int id);
  Future<bool> deletePaymentMethod(int id);
  bool isCurrentPlan(PlanModel plan);
  bool get hasBlockingCurrentSubscription;
}

class PlansControllerImp extends PlansController {
  bool _isRetryPolling = false;
  static const List<int> _retryPollingDelaysInSeconds = [2, 3, 5, 8, 13, 21];

  void _setRetryStatus({
    required String type,
    String? message,
    bool notify = true,
  }) {
    retryStatusType = type;
    retryStatusMessage = message;
    if (notify) {
      update();
    }
  }

  @override
  void onInit() {
    getPlans();
    loadBillingState();
    super.onInit();
  }

  @override
  Future<void> getPlans() async {
    if (isLoading) return;

    isLoading = true;
    update();

    ApiResponse response = await plansData.getPlans();

    if (response.isSuccess) {
      plans = response.data;
    }

    isLoading = false;
    update();
  }

  @override
  Future<void> loadBillingState() async {
    if (isBillingLoading) return;

    isBillingLoading = true;
    update();

    final subscriptionResponse = await billingData.getCurrentSubscription();
    if (subscriptionResponse.isSuccess) {
      currentSubscription = subscriptionResponse.data as Map<String, dynamic>?;
    } else if (subscriptionResponse.statusCode == 404) {
      // No active subscription is a valid state.
      currentSubscription = null;
    }
    _persistSubscriptionSnapshot();

    hasPaymentMethod = false;
    hasDefaultPaymentMethod = false;
    defaultPaymentMethodStatus = null;
    canRetryPayment = false;
    paymentMethods = [];
    defaultPaymentMethodId = null;

    final methodsResponse = await billingData.getPaymentMethods();
    if (methodsResponse.isSuccess &&
        methodsResponse.data is Map<String, dynamic>) {
      final payload = methodsResponse.data as Map<String, dynamic>;
      final methods = payload['methods'];
      if (methods is List) {
        paymentMethods = methods
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        hasPaymentMethod = paymentMethods.isNotEmpty;
      }

      hasDefaultPaymentMethod = payload['has_default_payment_method'] == true;
      defaultPaymentMethodStatus = payload['default_method_status']?.toString();
      canRetryPayment = payload['can_retry'] == true;
      defaultPaymentMethodId = paymentMethods
          .where((m) => m['is_default'] == true)
          .map((m) => m['id'])
          .whereType<int>()
          .cast<int?>()
          .firstWhere((id) => id != null, orElse: () => null);
    } else if (methodsResponse.isSuccess && methodsResponse.data is List) {
      // Backward compatibility with old API shape: data = [...]
      final methods = methodsResponse.data as List;
      hasPaymentMethod = methods.isNotEmpty;

      Map<String, dynamic>? defaultMethod;
      for (final item in methods) {
        if (item is! Map<String, dynamic>) continue;
        if (item['is_default'] == true) {
          defaultMethod = item;
          break;
        }
      }
      if (defaultMethod == null) {
        for (final item in methods) {
          if (item is! Map<String, dynamic>) continue;
          if (item['status'] == 'active') {
            defaultMethod = item;
            break;
          }
        }
      }

      paymentMethods = methods
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      hasDefaultPaymentMethod = defaultMethod != null;
      defaultPaymentMethodStatus = defaultMethod?['status']?.toString();
      canRetryPayment = defaultPaymentMethodStatus == 'active';
      defaultPaymentMethodId = defaultMethod?['id'] as int?;
    }

    isBillingLoading = false;
    update();
  }

  @override
  Future<void> cancelSubscription() async {
    if (isActionLoading || currentSubscription == null) return;
    isActionLoading = true;
    update();

    final response = await billingData.cancelSubscription();
    if (response.isSuccess) {
      customSnackBar(
        text: 'تم إيقاف التجديد التلقائي',
        snackType: SnackBarType.correct,
      );
    }

    isActionLoading = false;
    await loadBillingState();
    update();
  }

  @override
  Future<void> resumeSubscription() async {
    if (isActionLoading || currentSubscription == null) return;
    isActionLoading = true;
    update();

    final response = await billingData.resumeSubscription();
    if (response.isSuccess) {
      customSnackBar(
        text: 'تم تفعيل التجديد التلقائي',
        snackType: SnackBarType.correct,
      );
    }

    isActionLoading = false;
    await loadBillingState();
    update();
  }

  @override
  Future<void> retryPayment() async {
    if (isActionLoading || _isRetryPolling || currentSubscription == null) {
      return;
    }
    isActionLoading = true;
    _setRetryStatus(
      type: 'pending',
      message: 'جاري تنفيذ إعادة محاولة الدفع...',
      notify: false,
    );
    update();

    final response = await billingData.retryPayment();
    if (response.isSuccess) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      final merchantReferenceId = data['merchant_reference_id']?.toString();
      final gatewayStatus = data['gateway_status']?.toString() ?? 'unknown';
      final finalized = data['finalized'] == true;
      final verified = data['verified'] == true;
      final failureCode = data['failure_code']?.toString();
      final failureReason = data['failure_reason']?.toString();

      customSnackBar(
        text:
            'تم إرسال محاولة الدفع (${merchantReferenceId ?? '-'}) - الحالة: $gatewayStatus',
        snackType: finalized && verified
            ? SnackBarType.correct
            : SnackBarType.info,
      );

      if (merchantReferenceId != null &&
          merchantReferenceId.isNotEmpty &&
          !finalized) {
        await _pollRetryVerification(merchantReferenceId);
      } else if (finalized && verified) {
        _setRetryStatus(
          type: 'success',
          message: 'تم تأكيد عملية الدفع بنجاح.',
          notify: false,
        );
      } else if (finalized) {
        final failureMessage = _resolveFailureMessage(
          gatewayStatus: gatewayStatus,
          failureCode: failureCode,
          failureReason: failureReason,
        );
        _setRetryStatus(type: 'failed', message: failureMessage, notify: false);
      }
    } else {
      final reasonKey = response.key ?? '';
      final reasonMessage = _mapRetryReasonKey(reasonKey);
      _setRetryStatus(type: 'failed', message: reasonMessage, notify: false);
    }

    isActionLoading = false;
    await loadBillingState();
    if (currentSubscription?['status'] == 'active') {
      _setRetryStatus(
        type: 'success',
        message: 'الاشتراك نشط الآن.',
        notify: false,
      );
    }
    update();
  }

  String _mapRetryReasonKey(String key) {
    return switch (key) {
      'billing.retry.backoff_not_elapsed' =>
        'لا يمكن إعادة المحاولة الآن. حاول بعد انتهاء فترة الانتظار.',
      'billing.retry.max_attempts_reached' =>
        'تم الوصول للحد الأقصى من المحاولات لهذه الفترة.',
      'billing.retry.already_paid_for_period' => 'تم دفع هذه الفترة مسبقًا.',
      'billing.retry.no_active_payment_method' =>
        'لا توجد وسيلة دفع افتراضية فعّالة.',
      _ => 'تعذر إرسال إعادة المحاولة. حاول مرة أخرى.',
    };
  }

  @override
  Future<void> purchasePlan(PlanModel plan, {int? paymentMethodId}) async {
    if (isActionLoading) return;

    isActionLoading = true;
    actionPlanId = plan.id;
    update();

    final response = await billingData.purchasePlan(
      planId: plan.id,
      paymentMethodId: paymentMethodId,
    );
    if (response.isSuccess) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final merchantReferenceId = data['merchant_reference_id']?.toString();
      final finalized = data['finalized'] == true;
      final verified = data['verified'] == true;
      final gatewayStatus = data['gateway_status']?.toString() ?? 'unknown';
      final failureCode = data['failure_code']?.toString();
      final failureReason = data['failure_reason']?.toString();

      if (finalized && !verified) {
        customSnackBar(
          text: _resolveFailureMessage(
            gatewayStatus: gatewayStatus,
            failureCode: failureCode,
            failureReason: failureReason,
          ),
          snackType: SnackBarType.error,
        );
      } else if (merchantReferenceId != null &&
          merchantReferenceId.isNotEmpty &&
          !finalized) {
        customSnackBar(
          text: 'تم إرسال طلب الشراء بنجاح.',
          snackType: SnackBarType.correct,
        );
        await _pollRetryVerification(merchantReferenceId);
      } else if (verified) {
        customSnackBar(
          text: 'تمت عملية الشراء بنجاح.',
          snackType: SnackBarType.correct,
        );
      }
    } else {
      final message = switch (response.key ?? '') {
        'billing.purchase.active_subscription_exists' =>
          'لا يمكنك شراء باقة جديدة قبل انتهاء باقتك الحالية.',
        'billing.purchase.no_active_payment_method' =>
          'يلزم اختيار وسيلة دفع افتراضية فعالة أولاً.',
        'billing.purchase.invalid_payment_method' =>
          'وسيلة الدفع المختارة غير متاحة. اختر وسيلة أخرى.',
        _ => response.message ?? 'تعذر إتمام عملية الشراء.',
      };
      customSnackBar(text: message, snackType: SnackBarType.error);
    }

    isActionLoading = false;
    actionPlanId = null;
    await loadBillingState();
    update();
  }

  Future<void> _pollRetryVerification(String merchantReferenceId) async {
    if (_isRetryPolling) return;
    _isRetryPolling = true;

    try {
      for (final delay in _retryPollingDelaysInSeconds) {
        await Future.delayed(Duration(seconds: delay));

        final verifyResponse = await billingData.verifyPayment(
          merchantReferenceId: merchantReferenceId,
        );
        if (!verifyResponse.isSuccess ||
            verifyResponse.data is! Map<String, dynamic>) {
          continue;
        }

        final verifyData = verifyResponse.data as Map<String, dynamic>;
        final finalized = verifyData['finalized'] == true;
        final verified = verifyData['verified'] == true;
        final gatewayStatus =
            verifyData['gateway_status']?.toString() ?? 'unknown';
        final failureCode = verifyData['failure_code']?.toString();
        final failureReason = verifyData['failure_reason']?.toString();

        final stopStatuses = {'failed', 'expired'};
        final shouldStopEarly = stopStatuses.contains(gatewayStatus);
        if (finalized || shouldStopEarly) {
          final failureMessage = _resolveFailureMessage(
            gatewayStatus: gatewayStatus,
            failureCode: failureCode,
            failureReason: failureReason,
          );
          _setRetryStatus(
            type: verified ? 'success' : 'failed',
            message: verified ? 'تمت إعادة المحاولة بنجاح.' : failureMessage,
            notify: false,
          );
          customSnackBar(
            text: verified
                ? 'نجحت عملية الدفع ($merchantReferenceId)'
                : failureMessage,
            snackType: verified ? SnackBarType.correct : SnackBarType.error,
          );
          return;
        }
      }

      customSnackBar(
        text: 'العملية قيد المعالجة. سيتم تحديث الحالة عند إعادة التحميل.',
        snackType: SnackBarType.info,
      );
      _setRetryStatus(
        type: 'pending',
        message: 'التحقق مستمر. حدّث الصفحة خلال لحظات.',
        notify: false,
      );
    } finally {
      _isRetryPolling = false;
    }
  }

  String _resolveFailureMessage({
    String? gatewayStatus,
    String? failureCode,
    String? failureReason,
  }) {
    final reason = (failureReason ?? '').trim();
    if (reason.isNotEmpty) {
      return 'فشلت عملية الدفع: $reason';
    }

    final code = (failureCode ?? '').trim();
    final knownByCode = switch (code) {
      '05' => 'فشلت عملية الدفع: البطاقة مرفوضة من البنك أو الرصيد غير كافٍ.',
      '14' => 'فشلت عملية الدفع: رقم البطاقة غير صحيح.',
      '33' => 'فشلت عملية الدفع: البطاقة منتهية الصلاحية.',
      '34' => 'فشلت عملية الدفع: العملية مرفوضة للاشتباه.',
      _ => null,
    };
    if (knownByCode != null) {
      return knownByCode;
    }

    final status = (gatewayStatus ?? '').trim();
    if (status.isNotEmpty && status != 'unknown') {
      return 'فشلت عملية الدفع. الحالة: $status';
    }

    return 'فشلت عملية الدفع. يرجى المحاولة بوسيلة دفع أخرى.';
  }

  @override
  bool isCurrentPlan(PlanModel plan) {
    if (currentSubscription == null) return false;
    final status = (currentSubscription?['status'] ?? '')
        .toString()
        .toLowerCase();
    if (status != 'active' && status != 'past_due') {
      return false;
    }

    if (status == 'active') {
      final endDate = DateTime.tryParse(
        (currentSubscription?['end_date'] ?? '').toString(),
      );
      if (endDate != null && endDate.isBefore(DateTime.now())) {
        return false;
      }
    }

    return currentSubscription?['plan_id'] == plan.id;
  }

  bool get isAutoRenewEnabled {
    if (currentSubscription == null) return false;
    final cancelAtPeriodEnd =
        currentSubscription?['cancel_at_period_end'] == true;
    final autoRenew = currentSubscription?['auto_renew'] == true;
    return autoRenew && !cancelAtPeriodEnd;
  }

  bool get isPastDue {
    if (currentSubscription == null) return false;
    return currentSubscription?['status'] == 'past_due';
  }

  bool get hasActiveDefaultMethod {
    return hasDefaultPaymentMethod && defaultPaymentMethodStatus == 'active';
  }

  bool get hasBlockingActiveSubscription {
    if (currentSubscription == null) return false;
    final status = (currentSubscription?['status'] ?? '')
        .toString()
        .toLowerCase();
    if (status == 'past_due') return true;
    if (status != 'active') return false;

    final endDate = DateTime.tryParse(
      (currentSubscription?['end_date'] ?? '').toString(),
    );
    if (endDate == null) return true;

    return !endDate.isBefore(DateTime.now());
  }

  @override
  bool get hasBlockingCurrentSubscription => hasBlockingActiveSubscription;

  void _persistSubscriptionSnapshot() {
    final status = (currentSubscription?['status'] ?? 'none')
        .toString()
        .toLowerCase();
    final normalizedStatus = status.isEmpty ? 'none' : status;
    Shared.setValue(StorageKeys.subscriptionState, {
      'has_subscription': currentSubscription != null,
      'status': normalizedStatus,
      'plan_id': currentSubscription?['plan_id'],
      'end_date': currentSubscription?['end_date'],
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic>? get cachedSubscriptionSnapshot =>
      Shared.getMapValueOrNull(StorageKeys.subscriptionState);

  bool get isCachedActiveSubscription {
    final cached = cachedSubscriptionSnapshot;
    if (cached == null) return false;
    return (cached['status'] ?? '').toString().toLowerCase() == 'active';
  }

  bool get shouldFetchSubscriptionOnAppOpen {
    final cached = cachedSubscriptionSnapshot;
    if (cached == null) return true;
    final status = (cached['status'] ?? '').toString().toLowerCase();
    return status != 'active';
  }

  @override
  Future<bool> setDefaultPaymentMethod(int id) async {
    final response = await billingData.setDefaultPaymentMethod(id: id);
    if (!response.isSuccess) {
      customSnackBar(
        text: response.message ?? 'تعذر تعيين البطاقة الافتراضية.',
        snackType: SnackBarType.error,
      );
      return false;
    }

    await loadBillingState();
    return true;
  }

  @override
  Future<bool> deletePaymentMethod(int id) async {
    final response = await billingData.deletePaymentMethod(id: id);
    if (!response.isSuccess) {
      customSnackBar(
        text: response.message ?? 'تعذر حذف وسيلة الدفع.',
        snackType: SnackBarType.error,
      );
      return false;
    }

    await loadBillingState();
    return true;
  }
}
