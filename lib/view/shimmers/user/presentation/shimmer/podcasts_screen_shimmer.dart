import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class PodcastsScreenShimmer extends StatelessWidget {
  const PodcastsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.all(width(16)),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.only(bottom: height(12)),
            child: Row(
              children: [
                ShimmerBox(
                  width: width(72),
                  height: width(72),
                  borderRadius: BorderRadius.circular(10),
                ),
                SizedBox(width: width(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: height(16), borderRadius: BorderRadius.circular(8)),
                      SizedBox(height: height(8)),
                      ShimmerBox(height: height(12), width: width(160), borderRadius: BorderRadius.circular(8)),
                      SizedBox(height: height(8)),
                      ShimmerBox(height: height(3), borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
