import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
import 'package:flutter/material.dart';

class AuthAppBar extends StatelessWidget {
  final String title;
  final bool isBackButton;
  const AuthAppBar({super.key, required this.title, this.isBackButton = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: height(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: getWidth(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isBackButton)
              CustomBackButton(
                color: scheme.onPrimary,
                isNormal: true,
              ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(bottom: height(4)),
              width: width(16),
              height: height(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: scheme.onPrimary,
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1, // For line-height equal to font size
                color: scheme.onPrimary,
              ),
            ),
            Spacer(),
            if (isBackButton) Spacer(),
          ],
        ),
      ),
    );
  }
}
