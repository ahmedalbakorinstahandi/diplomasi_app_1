import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moyasar/moyasar.dart';

enum AddPaymentMethodMode { verificationOnly, purchasePlan }

class AddPaymentMethodScreen extends StatefulWidget {
  final AddPaymentMethodMode mode;
  final PlanModel? plan;

  const AddPaymentMethodScreen({
    super.key,
    this.mode = AddPaymentMethodMode.verificationOnly,
    this.plan,
  });

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  static const int _verificationAmountMinor = 100;
  static const String _publishableKey = String.fromEnvironment(
    'MOYASAR_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_RCzfStZqmUzC6ju8sXncwE9BnerBQmbvUhrHXpG3',
  );

  final BillingData _billingData = BillingData();
  bool _isSaving = false;

  int _toMinorUnits(String amount) {
    final parsed = double.tryParse(amount.trim()) ?? 0;
    return (parsed * 100).round();
  }

  int get _amountMinor {
    if (widget.mode == AddPaymentMethodMode.purchasePlan &&
        widget.plan != null) {
      return _toMinorUnits(widget.plan!.price);
    }
    return _verificationAmountMinor;
  }

  String get _description {
    if (widget.mode == AddPaymentMethodMode.purchasePlan &&
        widget.plan != null) {
      return 'Purchase ${widget.plan!.name}';
    }
    return 'Card tokenization for subscription renewals';
  }

  PaymentConfig get _paymentConfig => PaymentConfig(
    publishableApiKey: _publishableKey,
    amount: _amountMinor,
    currency: 'SAR',
    description: _description,
    creditCard: CreditCardConfig(saveCard: true, manual: false),
    metadata: {
      'purpose': widget.mode == AddPaymentMethodMode.purchasePlan
          ? 'plan_purchase'
          : 'subscription_payment_method',
      if (widget.plan != null) 'plan_id': widget.plan!.id.toString(),
    },
  );

  Future<void> _handlePaymentResult(dynamic result) async {
    if (_isSaving) return;

    if (result is! PaymentResponse) {
      customSnackBar(
        text: 'لم نتمكن من معالجة نتيجة الدفع. حاول مرة أخرى.',
        snackType: SnackBarType.error,
      );
      return;
    }

    final status = result.status;
    if (status == PaymentStatus.failed) {
      customSnackBar(
        text: 'فشلت إضافة البطاقة. يرجى المحاولة مرة أخرى.',
        snackType: SnackBarType.error,
      );
      return;
    }

    if (status == PaymentStatus.initiated) {
      customSnackBar(
        text: 'يرجى إكمال خطوة التحقق البنكي...',
        snackType: SnackBarType.info,
      );
      return;
    }

    final isSuccessfulStatus = {
      PaymentStatus.paid,
      PaymentStatus.authorized,
      PaymentStatus.captured,
    }.contains(status);

    if (!isSuccessfulStatus) {
      customSnackBar(
        text: 'حالة الدفع غير مدعومة لحفظ البطاقة.',
        snackType: SnackBarType.info,
      );
      return;
    }

    final source = result.source;
    if (source is! CardPaymentResponseSource) {
      customSnackBar(
        text: 'مصدر البطاقة غير متاح للحفظ.',
        snackType: SnackBarType.error,
      );
      return;
    }

    final token = source.token?.trim();
    final paymentId = result.id.trim();
    if ((token == null || token.isEmpty) && paymentId.isEmpty) {
      customSnackBar(
        text: 'لم يتم إرجاع token أو payment_id من بوابة الدفع.',
        snackType: SnackBarType.error,
      );
      return;
    }

    final digits = source.number.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : null;

    setState(() => _isSaving = true);
    final isPurchaseMode = widget.mode == AddPaymentMethodMode.purchasePlan;
    final saveResponse = isPurchaseMode
        ? await _billingData.purchasePlanWithPayment(
            planId: widget.plan!.id,
            gatewayPaymentId: paymentId,
            token: token,
            brand: source.company.name,
            last4: last4,
            meta: {
              'gateway_payment_id': result.id,
              'gateway_status': status.name,
              'source_gateway_id': source.gatewayId,
              'token_source': token == null || token.isEmpty
                  ? 'gateway_fetch_fallback'
                  : 'sdk_response',
            },
          )
        : await _billingData.storePaymentMethod(
            token: token,
            gatewayPaymentId: paymentId.isEmpty ? null : paymentId,
            status: 'active',
            brand: source.company.name,
            last4: last4,
            isDefault: true,
            refundVerification: true,
            verificationAmountMinor: _verificationAmountMinor,
            meta: {
              'gateway_payment_id': result.id,
              'gateway_status': status.name,
              'source_gateway_id': source.gatewayId,
              'token_source': token == null || token.isEmpty
                  ? 'gateway_fetch_fallback'
                  : 'sdk_response',
            },
          );
    setState(() => _isSaving = false);

    if (!saveResponse.isSuccess) {
      customSnackBar(
        text: isPurchaseMode
            ? (saveResponse.message ?? 'فشل إتمام شراء الباقة.')
            : 'تمت العملية لكن فشل حفظ البطاقة. أعد المحاولة.',
        snackType: SnackBarType.error,
      );
      return;
    }

    customSnackBar(
      text: isPurchaseMode
          ? 'تمت عملية الشراء بنجاح وتم حفظ البطاقة للتجديد.'
          : 'تمت إضافة وسيلة الدفع بنجاح. سيتم رد مبلغ التحقق تلقائيًا.',
      snackType: SnackBarType.correct,
    );
    if (mounted) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MyScaffold(
      appBar: AppBar(title: const Text('إضافة وسيلة دفع')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mode == AddPaymentMethodMode.purchasePlan
                  ? 'سيتم خصم قيمة الباقة مباشرة وحفظ البطاقة للتجديد التلقائي.'
                  : 'سيتم استخدام Moyasar SDK لحفظ بطاقة التجديد التلقائي.',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            if (widget.mode == AddPaymentMethodMode.verificationOnly) ...[
              Text(
                'ملاحظة: سيتم تنفيذ عملية تحقق صغيرة (100 هللة).',
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                'سيتم رد مبلغ التحقق (1 ريال) تلقائيًا بعد حفظ البطاقة.',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ] else ...[
              Text(
                'المبلغ الذي سيُخصم الآن: ${widget.plan?.price ?? '-'} SAR',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 16),
            if (_publishableKey.isEmpty)
              Text(
                'MOYASAR_PUBLISHABLE_KEY غير مضبوط. شغّل التطبيق مع --dart-define.',
                style: TextStyle(color: scheme.error),
                textDirection: TextDirection.rtl,
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: CreditCard(
                        config: _paymentConfig,
                        locale: const Localization.ar(),
                        onPaymentResult: _handlePaymentResult,
                      ),
                    ),
                    if (_isSaving)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.08),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
