import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/back_button.dart';
import 'package:flutter/material.dart';

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? textColor;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: backgroundColor ?? scheme.surface,
      elevation: 0,
      leading: CustomBackButton(
        color: scheme.onSurface,
        isNormal: true,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: emp(18),
          fontWeight: FontWeight.w600,
          color: textColor ?? scheme.onSurface,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
