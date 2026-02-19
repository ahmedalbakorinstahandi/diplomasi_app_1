import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class DeleteAccountButton extends StatelessWidget {
  final VoidCallback? onTap;

  const DeleteAccountButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: width(12),
            vertical: height(8),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'حذف الحساب',
          style: TextStyle(
            fontSize: emp(12),
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
            decoration: TextDecoration.underline,
            decorationColor: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

