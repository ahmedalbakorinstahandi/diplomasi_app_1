import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class LevelsScreenShimmer extends StatelessWidget {
  const LevelsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(16)),
        child: Column(
          children: [
            SizedBox(height: height(12)),
            ...List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: height(12)),
                child: ShimmerBox(
                  height: height(86),
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }),
            SizedBox(height: height(8)),
            ShimmerBox(
              height: height(52),
              borderRadius: BorderRadius.circular(14),
            ),
            SizedBox(height: height(24)),
          ],
        ),
      ),
    );
  }
}

