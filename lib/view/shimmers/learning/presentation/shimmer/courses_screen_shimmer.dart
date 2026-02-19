import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class CoursesScreenShimmer extends StatelessWidget {
  const CoursesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Column(
        children: [
          // Header placeholder
          Container(
            height: height(170),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: width(16)),
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.45,
                child: ShimmerBox(
                  height: emp(20),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width(16)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      height: height(120),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    SizedBox(height: height(10)),
                    const ShimmerBox(height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
                    const SizedBox(height: 8),
                    const FractionallySizedBox(
                      widthFactor: 0.65,
                      child: ShimmerBox(height: 12, borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: height(24)),
        ],
      ),
    );
  }
}

