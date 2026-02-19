import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class GlossaryScreenShimmer extends StatelessWidget {
  const GlossaryScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(14)),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          separatorBuilder: (_, __) => SizedBox(height: height(10)),
          itemBuilder: (context, index) {
            return ShimmerBox(
              height: height(86),
              borderRadius: BorderRadius.circular(16),
            );
          },
        ),
      ),
    );
  }
}
