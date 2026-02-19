import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

class EditProfileSaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const EditProfileSaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          padding: EdgeInsets.symmetric(vertical: height(16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                ),
              )
            : Text(
                'حفظ التغييرات',
                style: TextStyle(
                  fontSize: emp(16),
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
      ),
    );
  }
}

