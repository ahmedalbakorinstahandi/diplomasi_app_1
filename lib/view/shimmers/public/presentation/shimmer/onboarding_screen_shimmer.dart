import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class OnboardingScreenShimmer extends StatelessWidget {
  const OnboardingScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
        child: Column(
          children: [
            SizedBox(height: height(20)),
            ShimmerBox(
              height: getHeight() * 0.45,
              borderRadius: BorderRadius.circular(24),
            ),
            SizedBox(height: height(22)),
            const FractionallySizedBox(widthFactor: 0.6, child: ShimmerBox(height: 18)),
            SizedBox(height: height(12)),
            const ShimmerLines(count: 3, lineHeight: 12),
            SizedBox(height: height(26)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerCircle(size: 10),
                ),
              ),
            ),
            SizedBox(height: height(28)),
            ShimmerBox(
              height: height(52),
              borderRadius: BorderRadius.circular(14),
            ),
          ],
        ),
      ),
    );
  }
}

