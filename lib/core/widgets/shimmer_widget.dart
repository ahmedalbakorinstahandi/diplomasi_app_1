import 'package:flutter/material.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-adaptive shimmer wrapper and primitives.
class ShimmerWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1100),
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: baseColor ?? context.appColors.shimmerBase,
            highlightColor: highlightColor ?? context.appColors.shimmerHighlight,
            period: period,
            child: child,
          )
        : child;
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        borderRadius: borderRadius,
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: context.appColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ShimmerLines extends StatelessWidget {
  final int count;
  final double lineHeight;
  final double gap;
  final double lastLineWidthFactor;

  const ShimmerLines({
    super.key,
    this.count = 3,
    this.lineHeight = 12,
    this.gap = 8,
    this.lastLineWidthFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (index) {
        final isLast = index == count - 1;
        return FractionallySizedBox(
          widthFactor: isLast ? lastLineWidthFactor : 1,
          child: ShimmerBox(
            height: lineHeight,
            borderRadius: BorderRadius.circular(8),
            margin: EdgeInsets.only(bottom: index == count - 1 ? 0 : gap),
          ),
        );
      }),
    );
  }
}
