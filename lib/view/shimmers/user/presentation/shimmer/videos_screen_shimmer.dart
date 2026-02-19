import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class VideosScreenShimmer extends StatelessWidget {
  const VideosScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.all(width(16)),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Video Player Shimmer
            ShimmerBox(
              height: height(250),
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(height: height(16)),
            // Videos List Shimmer
            ...List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: height(12)),
                child: Row(
                  children: [
                    ShimmerBox(
                      width: width(120),
                      height: height(80),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    SizedBox(width: width(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShimmerBox(
                            height: height(16),
                            width: width(150),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          SizedBox(height: height(8)),
                          ShimmerBox(
                            height: height(12),
                            width: width(100),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
