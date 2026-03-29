import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tappable Terms of Use + Privacy Policy line for subscription / paywall (App Review 3.1.2).
class SubscriptionLegalConsent extends StatelessWidget {
  const SubscriptionLegalConsent({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseSize = compact ? 12.0 : 13.0;
    final baseStyle = TextStyle(
      fontSize: emp(baseSize),
      height: 1.4,
      color: scheme.onSurface.withOpacity(0.82),
    );
    final linkStyle = baseStyle.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width(compact ? 4 : 20),
        vertical: height(compact ? 0 : 8),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: width(4),
        runSpacing: height(4),
        children: [
          Text('subscription_legal_prefix'.tr, style: baseStyle, textAlign: TextAlign.center),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.termsConditions),
            child: Text('terms_conditions'.tr, style: linkStyle),
          ),
          Text('subscription_legal_between'.tr, style: baseStyle),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            child: Text('privacy_policy'.tr, style: linkStyle),
          ),
          Text('subscription_legal_suffix'.tr, style: baseStyle),
        ],
      ),
    );
  }
}
