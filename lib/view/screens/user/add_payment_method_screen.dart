import 'package:diplomasi_app/core/config/moyasar_env_keys.dart';
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
  static const String _fallbackPublishableKey = String.fromEnvironment(
    'MOYASAR_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  final BillingData _billingData = BillingData();
  bool _isSaving = false;
  bool _resultHandled = false;
  bool _isDisposed = false;
  bool _configReady = false;
  bool _configError = false;
  String _publishableKey = '';
  String _billingCurrency = 'USD';
  PaymentConfig? _paymentConfig;
  late final ValueKey<String> _creditCardKey;

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

  @override
  void initState() {
    super.initState();
    _creditCardKey = ValueKey<String>(
      'moyasar_card_${widget.mode.name}_${widget.plan?.id ?? 'none'}',
    );
    _loadMoyasarConfig();
  }

  Future<void> _loadMoyasarConfig() async {
    final res = await _billingData.getMoyasarPublicConfig();
    var mode = MoyasarEnvKeys.modeFromEnv();
    var key = '';
    String currency = MoyasarEnvKeys.billingCurrencyFromEnv();
    if (res.success && res.data is Map) {
      final m = Map<String, dynamic>.from(res.data as Map);
      mode = MoyasarEnvKeys.normalizeMode(m['mode']?.toString());
      final c = (m['currency'] ?? '').toString().trim();
      if (c.isNotEmpty) {
        currency = c.toUpperCase();
      }
      final serverKey = (m['publishable_key'] ?? '').toString().trim();
      final local = MoyasarEnvKeys.publishableForMode(mode);
      key = (local != null && local.isNotEmpty) ? local : serverKey;
    } else {
      mode = MoyasarEnvKeys.modeFromEnv();
      key = MoyasarEnvKeys.publishableForMode(mode) ?? '';
    }
    if (key.isEmpty && _fallbackPublishableKey.isNotEmpty) {
      key = _fallbackPublishableKey.trim();
    }
    if (!mounted) {
      return;
    }
    if (key.isEmpty) {
      setState(() {
        _configReady = true;
        _configError = true;
      });
      return;
    }
    setState(() {
      _publishableKey = key;
      _billingCurrency = currency;
      _paymentConfig = PaymentConfig(
        publishableApiKey: _publishableKey,
        amount: _amountMinor,
        currency: _billingCurrency,
        description: _description,
        creditCard: CreditCardConfig(saveCard: true, manual: false),
        metadata: {
          'purpose': widget.mode == AddPaymentMethodMode.purchasePlan
              ? 'plan_purchase'
              : 'subscription_payment_method',
          if (widget.plan != null) 'plan_id': widget.plan!.id.toString(),
        },
      );
      _configReady = true;
      _configError = false;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String _moyasarNonPaymentErrorText(dynamic result) {
    if (result is ApiError) {
      return 'فشلت العملية: ${result.message}';
    }
    if (result is AuthError) {
      return 'مفتاح Moyasar غير صالح: ${result.message}';
    }
    if (result is ValidationError) {
      final msg = result.message.trim();
      return msg.isNotEmpty
          ? 'بيانات غير مقبولة: $msg'
          : 'بيانات الدفع غير صالحة.';
    }
    if (result is UnspecifiedError) {
      return 'فشل غير متوقع: ${result.message}';
    }
    if (result is NetworkError) {
      return 'تعذر الاتصال ببوابة الدفع. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (result is TimeoutError) {
      return 'انتهت مهلة الاتصال ببوابة الدفع. حاول مرة أخرى.';
    }
    if (result is PaymentCanceledError) {
      return 'تم إلغاء الدفع.';
    }
    if (result is UnprocessableTokenError) {
      return result.message;
    }
    return 'لم نتمكن من معالجة نتيجة الدفع. حاول مرة أخرى.';
  }

  Future<void> _handlePaymentResult(dynamic result) async {
    if (_isSaving || _resultHandled || _isDisposed || !mounted) return;

    if (result is! PaymentResponse) {
      customSnackBar(
        text: _moyasarNonPaymentErrorText(result),
        snackType: SnackBarType.error,
      );
      return;
    }

    final status = result.status;
    if (status == PaymentStatus.failed) {
      String? gatewayMsg;
      if (result.source is CardPaymentResponseSource) {
        gatewayMsg = (result.source as CardPaymentResponseSource).message
            ?.trim();
      }
      final detail = (gatewayMsg != null && gatewayMsg.isNotEmpty)
          ? gatewayMsg
          : null;
      customSnackBar(
        text: detail != null
            ? 'فشلت عملية الدفع: $detail'
            : 'فشلت عملية الدفع. يرجى التحقق من بيانات البطاقة والمحاولة مرة أخرى.',
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

    _resultHandled = true;
    if (mounted && !_isDisposed) {
      setState(() => _isSaving = true);
    }
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
    if (!mounted || _isDisposed) {
      return;
    }
    setState(() => _isSaving = false);

    if (!saveResponse.isSuccess) {
      _resultHandled = false;
      customSnackBar(
        text:
            saveResponse.message ??
            (isPurchaseMode
                ? 'فشل إتمام شراء الباقة.'
                : 'تمت العملية لكن فشل حفظ البطاقة. أعد المحاولة.'),
        snackType: SnackBarType.error,
      );
      return;
    }

    final responseData = saveResponse.data is Map<String, dynamic>
        ? saveResponse.data as Map<String, dynamic>
        : <String, dynamic>{};
    final refundMeta = responseData['meta'] is Map<String, dynamic>
        ? responseData['meta']['verification_refund']
        : null;
    final refundSuccess =
        refundMeta is Map<String, dynamic> && refundMeta['success'] == true;

    customSnackBar(
      text: isPurchaseMode
          ? 'تمت عملية الشراء بنجاح وتم حفظ البطاقة للتجديد.'
          : refundSuccess
          ? 'تمت إضافة وسيلة الدفع بنجاح وتم رد 1.00 USD.'
          : 'تمت إضافة وسيلة الدفع بنجاح. سيصل رد 1.00 USD خلال وقت قصير.',
      snackType: SnackBarType.correct,
    );
    if (mounted && !_isDisposed) {
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
                'ملاحظة: سيتم تنفيذ عملية تحقق صغيرة (1.00 USD).',
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                'سيتم رد مبلغ التحقق (1.00 USD) تلقائيًا بعد حفظ البطاقة.',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ] else ...[
              Text(
                'المبلغ الذي سيُخصم الآن: ${widget.plan?.price ?? '-'} USD',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                'الأسعار بالدولار الأمريكي (USD).',
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 16),
            if (!_configReady)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_configError || _paymentConfig == null)
              Expanded(
                child: Text(
                  'تعذر تحميل إعدادات Moyasar من الخادم. تحقق من الاتصال أو عرّف MOYASAR_PUBLISHABLE_KEY كبديل (--dart-define).',
                  style: TextStyle(color: scheme.error),
                  textDirection: TextDirection.rtl,
                ),
              )
            else
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: CreditCard(
                        key: _creditCardKey,
                        config: _paymentConfig!,
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
