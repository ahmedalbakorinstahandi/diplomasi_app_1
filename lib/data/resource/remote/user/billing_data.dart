import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:get/get.dart';

class BillingData {
  ApiService apiService = Get.find();

  Future<ApiResponse> getCurrentSubscription() async {
    return await apiService.get(EndPoints.billingSubscription);
  }

  Future<ApiResponse> cancelSubscription() async {
    return await apiService.post(EndPoints.billingSubscriptionCancel);
  }

  Future<ApiResponse> resumeSubscription() async {
    return await apiService.post(EndPoints.billingSubscriptionResume);
  }

  Future<ApiResponse> retryPayment() async {
    return await apiService.post(EndPoints.billingSubscriptionRetryPayment);
  }

  Future<ApiResponse> purchasePlan({
    required int planId,
    int? paymentMethodId,
  }) async {
    return await apiService.post(
      EndPoints.billingSubscriptionPurchase,
      data: {
        'plan_id': planId,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      },
    );
  }

  Future<ApiResponse> purchasePlanWithPayment({
    required int planId,
    required String gatewayPaymentId,
    String? token,
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
    Map<String, dynamic>? meta,
  }) async {
    return await apiService.post(
      EndPoints.billingSubscriptionPurchaseWithPayment,
      data: {
        'plan_id': planId,
        'gateway_payment_id': gatewayPaymentId,
        'token': token,
        'brand': brand,
        'last4': last4,
        'exp_month': expMonth,
        'exp_year': expYear,
        'meta': meta,
      },
    );
  }

  Future<ApiResponse> verifyPayment({
    required String merchantReferenceId,
  }) async {
    return await apiService.post(
      EndPoints.billingPaymentsVerify,
      data: {'merchant_reference_id': merchantReferenceId},
    );
  }

  Future<ApiResponse> getPaymentMethods() async {
    return await apiService.get(EndPoints.billingPaymentMethods);
  }

  Future<ApiResponse> storePaymentMethod({
    String? token,
    String? gatewayPaymentId,
    required String status,
    String? brand,
    String? last4,
    int? expMonth,
    int? expYear,
    bool isDefault = true,
    bool refundVerification = false,
    int? verificationAmountMinor,
    Map<String, dynamic>? meta,
  }) async {
    return await apiService.post(
      EndPoints.billingPaymentMethods,
      data: {
        'token': token,
        'gateway_payment_id': gatewayPaymentId,
        'status': status,
        'brand': brand,
        'last4': last4,
        'exp_month': expMonth,
        'exp_year': expYear,
        'is_default': isDefault,
        'refund_verification': refundVerification,
        'verification_amount_minor': verificationAmountMinor,
        'meta': meta,
      },
    );
  }

  Future<ApiResponse> setDefaultPaymentMethod({required int id}) async {
    return await apiService.post(
      EndPoints.billingPaymentMethodSetDefault,
      pathVariables: {'id': id},
    );
  }

  Future<ApiResponse> deletePaymentMethod({required int id}) async {
    return await apiService.delete(
      EndPoints.billingPaymentMethodDelete,
      pathVariables: {'id': id},
    );
  }

  Future<ApiResponse> getInvoices({
    int page = 1,
    int perPage = 20,
    Map<String, dynamic>? filters,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (filters != null) {
      params.addAll(filters);
    }

    return await apiService.get(
      EndPoints.billingInvoices,
      params: params,
    );
  }

  Future<ApiResponse> getPayments({
    int page = 1,
    int perPage = 20,
    Map<String, dynamic>? filters,
  }) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (filters != null) {
      params.addAll(filters);
    }

    return await apiService.get(
      EndPoints.billingPayments,
      params: params,
    );
  }

  Future<ApiResponse> getInvoiceById({
    required int id,
    bool includePdf = false,
  }) async {
    return await apiService.get(
      EndPoints.billingInvoice,
      pathVariables: {'id': id},
      params: {'include_pdf': includePdf ? 1 : 0},
    );
  }
}
