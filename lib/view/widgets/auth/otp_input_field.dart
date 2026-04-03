import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _OtpDigitPasteFormatter extends TextInputFormatter {
  _OtpDigitPasteFormatter({
    required this.fieldIndex,
    required this.otpLength,
    required this.onPasteCode,
  });

  final int fieldIndex;
  final int otpLength;
  final void Function(String digits) onPasteCode;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 1) {
      onPasteCode(digits);
      final ch = fieldIndex < digits.length && fieldIndex < otpLength
          ? digits[fieldIndex]
          : '';
      return TextEditingValue(
        text: ch,
        selection: TextSelection.collapsed(offset: ch.length),
      );
    }
    if (digits.length == 1) {
      return TextEditingValue(
        text: digits,
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    return const TextEditingValue(text: '');
  }
}

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;
  final int fieldIndex;
  final int otpLength;
  final void Function(String digits)? onMultiDigitPaste;

  const OtpInputField({
    super.key,
    required this.controller,
    this.autoFocus = false,
    this.onChanged,
    this.fieldIndex = 0,
    this.otpLength = 5,
    this.onMultiDigitPaste,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
        ),
        inputFormatters: [
          if (onMultiDigitPaste != null)
            _OtpDigitPasteFormatter(
              fieldIndex: fieldIndex,
              otpLength: otpLength,
              onPasteCode: onMultiDigitPaste!,
            )
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          onChanged?.call(value);
        },
      ),
    );
  }
}
