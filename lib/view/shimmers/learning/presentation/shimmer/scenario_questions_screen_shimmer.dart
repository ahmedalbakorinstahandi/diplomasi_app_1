import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class ScenarioDescriptionShimmer extends StatelessWidget {
  const ScenarioDescriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: height(20), horizontal: width(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FractionallySizedBox(widthFactor: 0.55, child: ShimmerBox(height: 18)),
            SizedBox(height: height(14)),
            ShimmerBox(
              height: height(160),
              borderRadius: BorderRadius.circular(16),
            ),
            SizedBox(height: height(16)),
            const ShimmerLines(count: 4, lineHeight: 12),
            SizedBox(height: height(20)),
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

class ScenarioQuestionShimmer extends StatelessWidget {
  const ScenarioQuestionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: height(20), horizontal: width(16)),
        child: Column(
          children: [
            ShimmerBox(
              height: height(200),
              borderRadius: BorderRadius.circular(16),
            ),
            SizedBox(height: height(16)),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: height(12)),
                child: ShimmerBox(
                  height: height(58),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            SizedBox(height: height(10)),
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

