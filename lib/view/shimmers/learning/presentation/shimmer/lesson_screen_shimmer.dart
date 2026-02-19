import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class LessonScreenShimmer extends StatelessWidget {
  const LessonScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Column(
        children: [
          // Header placeholder
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + height(16),
              left: width(16),
              right: width(16),
              bottom: height(16),
            ),
            child: Row(
              children: [
                ShimmerCircle(size: emp(36)),
                SizedBox(width: width(12)),
                Expanded(
                  child: ShimmerBox(
                    height: emp(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Video placeholder
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width(16)),
            child: ShimmerBox(
              height: height(210),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          SizedBox(height: height(16)),

          // Content blocks
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width(16)),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const ShimmerLines(count: 3, lineHeight: 12),
                  SizedBox(height: height(18)),
                  ShimmerBox(
                    height: height(120),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: height(12)),
                  ShimmerBox(
                    height: height(120),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: height(18)),
                  ShimmerBox(
                    height: height(54),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  SizedBox(height: height(24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

