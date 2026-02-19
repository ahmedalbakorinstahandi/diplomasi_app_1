import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:flutter/material.dart';

class PremiumBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const PremiumBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          // horizontal: width(16),
          vertical: height(16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width(16),
          vertical: height(20),
        ),
        decoration: BoxDecoration(
          color: colors.highlight.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(width: width(12)),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MySvgIcon(
                        path: Assets.icons.svg.crown,
                        color: scheme.primary,
                      ),
                      SizedBox(width: width(4)),
                      Text(
                        'المزيد بانتظارك✨!',
                        style: TextStyle(
                          fontSize: emp(16),
                          fontWeight: FontWeight.w600,
                          height: 19 / 16.0178,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height(6)),
                  Text(
                    'قم بالترقية للوصول إلى جميع الدروس والمزايا المتقدمة.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: emp(14),
                      height: 17 / 14.0156,
                      color: colors.textSecondary,
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
