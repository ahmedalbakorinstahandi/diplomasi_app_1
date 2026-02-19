import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class ArticlesScreenShimmer extends StatelessWidget {
  const ArticlesScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.all(width(16)),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: height(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    height: height(200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: height(12)),
                  ShimmerBox(
                    height: height(20),
                    width: width(200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  SizedBox(height: height(8)),
                  ShimmerBox(
                    height: height(16),
                    width: width(150),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  SizedBox(height: height(8)),
                  ShimmerBox(
                    height: height(16),
                    width: width(250),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
