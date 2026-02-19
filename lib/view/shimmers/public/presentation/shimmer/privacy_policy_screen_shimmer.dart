import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreenShimmer extends StatelessWidget {
  const PrivacyPolicyScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(20), vertical: height(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FractionallySizedBox(widthFactor: 0.5, child: ShimmerBox(height: 18)),
            SizedBox(height: height(14)),
            const ShimmerLines(count: 7, lineHeight: 12),
            SizedBox(height: height(18)),
            const FractionallySizedBox(widthFactor: 0.35, child: ShimmerBox(height: 16)),
            SizedBox(height: height(14)),
            const ShimmerLines(count: 8, lineHeight: 12),
          ],
        ),
      ),
    );
  }
}

