import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/widgets/auth/otp_input_field.dart';
import 'package:flutter/material.dart';

class AccountDeletionDialog extends StatefulWidget {
  final String email;
  final Function(String code) onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;
  final VoidCallback? onResend;
  final bool canResend;
  final int? resendTimer;

  const AccountDeletionDialog({
    super.key,
    required this.email,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
    this.onResend,
    this.canResend = true,
    this.resendTimer,
  });

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  String get code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width(24),
              vertical: height(24),
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.error.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        color: scheme.error,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: width(16)),
                    Expanded(
                      child: Text(
                        'تأكيد حذف الحساب',
                        style: TextStyle(
                          fontSize: emp(20),
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height(16)),
                // Warning Message
                Container(
                  padding: EdgeInsets.all(width(16)),
                  decoration: BoxDecoration(
                    color: scheme.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: scheme.error, size: 20),
                      SizedBox(width: width(12)),
                      Expanded(
                        child: Text(
                          'سيتم حذف جميع بياناتك بشكل نهائي. هذه العملية لا يمكن التراجع عنها.',
                          style: TextStyle(
                            fontSize: emp(14),
                            color: scheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height(24)),
                // Email Info
                Text(
                  'تم إرسال رمز التحقق إلى:',
                  style: TextStyle(fontSize: emp(14), color: colors.textSecondary),
                ),
                SizedBox(height: height(8)),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: emp(14),
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                SizedBox(height: height(24)),
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => OtpInputField(
                      controller: _controllers[index],
                      autoFocus: index == 0,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                SizedBox(height: height(24)),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: widget.isLoading ? null : widget.onCancel,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: height(14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: emp(16),
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.isLoading || code.length != 5
                            ? null
                            : () => widget.onConfirm(code),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.error,
                          padding: EdgeInsets.symmetric(vertical: height(14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: colors.border,
                        ),
                        child: widget.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: scheme.onError,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'حذف الحساب',
                                style: TextStyle(
                                  fontSize: emp(16),
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onError,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                if (widget.onResend != null) ...[
                  SizedBox(height: height(12)),
                  Center(
                    child: widget.canResend
                        ? TextButton(
                            onPressed: widget.isLoading
                                ? null
                                : widget.onResend,
                            child: Text(
                              'إعادة إرسال الرمز',
                              style: TextStyle(
                                fontSize: emp(14),
                                color: scheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            widget.resendTimer != null &&
                                    widget.resendTimer! > 0
                                ? 'إعادة إرسال الرمز خلال ${widget.resendTimer} ثانية'
                                : 'انتظر قبل إعادة الإرسال',
                            style: TextStyle(
                              fontSize: emp(12),
                              color: colors.textSecondary,
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
