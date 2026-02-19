import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isFeatured;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final bool actionEnabled;
  final bool isActionLoading;
  final Widget? managementWidget;

  const PlanCard({
    super.key,
    required this.plan,
    this.isFeatured = false,
    required this.actionLabel,
    this.onActionTap,
    this.actionEnabled = false,
    this.isActionLoading = false,
    this.managementWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: width(20), vertical: height(12)),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: null,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 16,
            offset: Offset(0, height(4)),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Crown and sparkles for featured/premium plan
          if (isFeatured) ...[
            Positioned(
              top: -height(20),
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MySvgIcon(
                    path: Assets.icons.svg.crown,
                    size: emp(40),
                    color: colors.highlight,
                  ),
                ],
              ),
            ),
          ],

          // Card content
          Padding(
            padding: EdgeInsets.only(
              top: isFeatured ? height(40) : height(24),
              left: width(20),
              right: width(20),
              bottom: height(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon (if available)
                if (plan.iconUrl != null && plan.iconUrl!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(bottom: height(16)),
                    child: CachedNetworkImage(
                      imageUrl: plan.iconUrl!,
                      width: width(60),
                      height: width(60),
                      errorWidget: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                    ),
                  ),

                // Price section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        // Current price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              '${plan.price} SAR',
                              style: TextStyle(
                                fontSize: emp(32),
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            SizedBox(width: width(8)),
                            // Show annual discount if applicable
                            if (plan.isAnnual)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width(8),
                                  vertical: height(4),
                                ),
                                decoration: BoxDecoration(
                                  color: colors.success.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'خصم ${_calculateAnnualDiscount(plan)}%',
                                  style: TextStyle(
                                    fontSize: emp(12),
                                    fontWeight: FontWeight.w600,
                                    color: colors.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: height(4)),
                        // Interval
                        Text(
                          plan.isAnnual ? '/سنة' : '/شهر',
                          style: TextStyle(
                            fontSize: emp(14),
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: height(16)),

                // Plan name
                Text(
                  _getPlanName(plan.name),
                  style: TextStyle(
                    fontSize: emp(24),
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                  textDirection: TextDirection.rtl,
                ),

                SizedBox(height: height(8)),

                // Description
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: emp(14),
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),

                // Special tagline for premium/lifetime plan
                if (isFeatured) ...[
                  SizedBox(height: height(12)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width(12),
                      vertical: height(8),
                    ),
                    decoration: BoxDecoration(
                      color: colors.highlight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            'أكثر من 80% من المتعلمين يختارون هذه الخطة مدى الحياة!',
                            style: TextStyle(
                              fontSize: emp(12),
                              fontWeight: FontWeight.w600,
                              color: colors.highlightText,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: height(20)),

                // Divider
                Divider(color: colors.divider, thickness: 1),

                SizedBox(height: height(20)),

                // Features list
                ...plan.features.map(
                  (feature) => Padding(
                    padding: EdgeInsets.only(bottom: height(12)),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkmark icon
                        Container(
                          width: width(24),
                          height: width(24),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: emp(16),
                            color: scheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: width(12)),
                        // Feature text
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: emp(14),
                              fontWeight: FontWeight.w400,
                              color: scheme.onSurface,
                              height: 1.5,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: height(24)),

                if (managementWidget != null) ...[
                  managementWidget!,
                  SizedBox(height: height(12)),
                ],

                // Action button
                _buildActionButton(
                  context: context,
                  colors: colors,
                  scheme: scheme,
                  label: actionLabel,
                  onTap: onActionTap,
                  isEnabled: actionEnabled,
                  isLoading: isActionLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanName(String name) {
    switch (name.toLowerCase()) {
      case 'basic':
        return 'الخطة الأساسية';
      case 'pro':
        return 'الخطة الاحترافية';
      case 'premium':
        return 'الخطة الدائمة';
      default:
        return name;
    }
  }

  int _calculateAnnualDiscount(PlanModel plan) {
    // Simple discount calculation - can be improved based on actual data
    if (plan.isAnnual) {
      // Example: if monthly is $19.99 and annual is $149, discount is ~38%
      // This is a placeholder - you might want to pass discount from API
      return 38;
    }
    return 0;
  }

  Widget _buildActionButton({
    required BuildContext context,
    required AppColors colors,
    required ColorScheme scheme,
    required String label,
    required VoidCallback? onTap,
    required bool isEnabled,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: Container(
      width: double.infinity,
      height: height(48),
      decoration: BoxDecoration(
        color: isEnabled ? scheme.primary : colors.surfaceCard,
        border: Border.all(
          color: isEnabled
              ? scheme.primary
              : colors.textSecondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: width(20),
                height: width(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isEnabled ? scheme.onPrimary : colors.textSecondary,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: emp(14),
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? scheme.onPrimary : colors.textSecondary,
                ),
                textDirection: TextDirection.rtl,
              ),
      ),
    ));
  }
}
