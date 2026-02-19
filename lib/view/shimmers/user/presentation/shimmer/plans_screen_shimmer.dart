import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class PlansScreenShimmer extends StatelessWidget {
  const PlansScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(14)),
        child: Column(
          children: [
            SizedBox(height: height(16)),
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: height(14)),
                child: ShimmerBox(
                  height: height(180),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
            SizedBox(height: height(24)),
          ],
        ),
      ),
    );
  }
}

