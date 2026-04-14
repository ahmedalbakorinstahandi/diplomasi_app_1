import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
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
  final DateTime? countdownTarget;
  final VoidCallback? onCountdownFinished;

  const PlanCard({
    super.key,
    required this.plan,
    this.isFeatured = false,
    required this.actionLabel,
    this.onActionTap,
    this.actionEnabled = false,
    this.isActionLoading = false,
    this.managementWidget,
    this.countdownTarget,
    this.onCountdownFinished,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final featuredBorderColor = Colors.orange;
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
        border: isFeatured
            ? Border.all(color: featuredBorderColor, width: 2)
            : null,
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
          // أيقونة تاج للخطة المميزة (is_featured من API)
          if (isFeatured) ...[
            Positioned(
              top: -height(20),
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(width(8)),
                    decoration: BoxDecoration(
                      color: featuredBorderColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: featuredBorderColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      size: emp(28),
                      color: Colors.white,
                    ),
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
                // صف واحد: الأيقونة + بجانبها تسمية (الأشهر أو المدة) والسعر
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    // تسمية بجانب الصورة: الأشهر للخطة المميزة، أو مدة الاشتراك
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: width(10),
                              vertical: height(5),
                            ),
                            decoration: BoxDecoration(
                              color: isFeatured
                                  ? featuredBorderColor.withOpacity(0.15)
                                  : scheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isFeatured
                                  ? 'الأشهر'
                                  : plan.displayIntervalLabel,
                              style: TextStyle(
                                fontSize: emp(12),
                                fontWeight: FontWeight.w700,
                                color: isFeatured
                                    ? featuredBorderColor
                                    : scheme.primary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(height: height(10)),
                          Text(
                            '${plan.price} USD',
                            style: TextStyle(
                              fontSize: emp(28),
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                          SizedBox(height: height(2)),
                          Text(
                            '/${plan.displayIntervalLabel}',
                            style: TextStyle(
                              fontSize: emp(13),
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          if (plan.isAnnual) ...[
                            SizedBox(height: height(4)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width(8),
                                vertical: height(3),
                              ),
                              decoration: BoxDecoration(
                                color: colors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'خصم ${_calculateAnnualDiscount(plan)}%',
                                style: TextStyle(
                                  fontSize: emp(11),
                                  fontWeight: FontWeight.w600,
                                  color: colors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: width(12)),
                    if (plan.iconUrl != null && plan.iconUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: plan.iconUrl!,
                        width: width(60),
                        height: width(60),
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: emp(32)),
                      ),
                  ],
                ),

                SizedBox(height: height(16)),

                // اسم الخطة + مدة الاشتراك
                Text(
                  plan.name.trim().isNotEmpty
                      ? '${plan.name} • ${plan.displayIntervalLabel}'
                      : plan.displayIntervalLabel,
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

                // عبارة ترويجية من API (caption) إن وُجدت بدل النص الثابت
                if (plan.caption != null && plan.caption!.trim().isNotEmpty) ...[
                  SizedBox(height: height(12)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width(12),
                      vertical: height(8),
                    ),
                    decoration: BoxDecoration(
                      color: (isFeatured ? Colors.orange : colors.highlight)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            plan.caption!,
                            style: TextStyle(
                              fontSize: emp(12),
                              fontWeight: FontWeight.w600,
                              color: isFeatured
                                  ? Colors.orange.shade800
                                  : colors.highlightText,
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

                if (countdownTarget != null) ...[
                  _AdaptivePlanCountdown(
                    target: countdownTarget!,
                    onFinished: onCountdownFinished,
                  ),
                  SizedBox(height: height(12)),
                ],

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

class _AdaptivePlanCountdown extends StatefulWidget {
  final DateTime target;
  final VoidCallback? onFinished;

  const _AdaptivePlanCountdown({required this.target, this.onFinished});

  @override
  State<_AdaptivePlanCountdown> createState() => _AdaptivePlanCountdownState();
}

class _AdaptivePlanCountdownState extends State<_AdaptivePlanCountdown> {
  Timer? _timer;
  late DateTime _now;
  bool _finishNotified = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _AdaptivePlanCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _finishNotified = false;
      _now = DateTime.now();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
      _maybeNotifyFinished();
    });
  }

  void _maybeNotifyFinished() {
    if (_finishNotified) return;
    if (widget.target.isAfter(_now)) return;
    _finishNotified = true;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final remaining = widget.target.difference(_now);
    final ended = remaining.inSeconds <= 0;
    final segments = ended ? const <_TimeSegment>[] : _buildSegments(remaining);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width(12), vertical: height(10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: emp(16),
                color: scheme.primary,
              ),
              SizedBox(width: width(6)),
              Text(
                'الوقت المتبقي من الاشتراك',
                style: TextStyle(
                  fontSize: emp(12),
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          SizedBox(height: height(10)),
          if (ended)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: width(12),
                vertical: height(8),
              ),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'انتهت المدة',
                style: TextStyle(
                  fontSize: emp(12.5),
                  fontWeight: FontWeight.w700,
                  color: scheme.onErrorContainer,
                ),
                textDirection: TextDirection.rtl,
              ),
            )
          else
            Wrap(
              spacing: width(8),
              runSpacing: height(8),
              children: segments
                  .map(
                    (segment) => Container(
                      width: width(72),
                      padding: EdgeInsets.symmetric(
                        horizontal: width(6),
                        vertical: height(6),
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: scheme.outlineVariant.withOpacity(0.45),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _twoDigits(segment.value),
                            style: TextStyle(
                              fontSize: emp(16),
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: height(3)),
                          Text(
                            segment.label,
                            style: TextStyle(
                              fontSize: emp(10.5),
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface.withOpacity(0.78),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (!ended) ...[
            SizedBox(height: height(4)),
          ],
        ],
      ),
    );
  }

  String _twoDigits(int value) => value < 10 ? '0$value' : '$value';

  List<_TimeSegment> _buildSegments(Duration remaining) {
    final days = remaining.inDays;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds;

    if (days >= 365) {
      final years = days ~/ 365;
      final months = (days % 365) ~/ 30;
      final remDays = (days % 365) % 30;
      return [
        _TimeSegment(years, 'سنة'),
        _TimeSegment(months, 'شهر'),
        _TimeSegment(remDays, 'يوم'),
      ];
    }

    if (days >= 30) {
      final months = days ~/ 30;
      final remDays = days % 30;
      final remHours = hours % 24;
      return [
        _TimeSegment(months, 'شهر'),
        _TimeSegment(remDays, 'يوم'),
        _TimeSegment(remHours, 'ساعة'),
      ];
    }

    if (days >= 1) {
      final remHours = hours % 24;
      final remMinutes = minutes % 60;
      return [
        _TimeSegment(days, 'يوم'),
        _TimeSegment(remHours, 'ساعة'),
        _TimeSegment(remMinutes, 'دقيقة'),
      ];
    }

    if (hours >= 1) {
      final remMinutes = minutes % 60;
      final remSeconds = seconds % 60;
      return [
        _TimeSegment(hours, 'ساعة'),
        _TimeSegment(remMinutes, 'دقيقة'),
        _TimeSegment(remSeconds, 'ثانية'),
      ];
    }

    if (minutes >= 1) {
      final remSeconds = seconds % 60;
      return [
        _TimeSegment(minutes, 'دقيقة'),
        _TimeSegment(remSeconds, 'ثانية'),
      ];
    }

    return [_TimeSegment(seconds, 'ثانية')];
  }
}

class _TimeSegment {
  final int value;
  final String label;

  const _TimeSegment(this.value, this.label);
}
