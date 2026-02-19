import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class LessonQuestionsScreenShimmer extends StatelessWidget {
  const LessonQuestionsScreenShimmer({super.key});

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

