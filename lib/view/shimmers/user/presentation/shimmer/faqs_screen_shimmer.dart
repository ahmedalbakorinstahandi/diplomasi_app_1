import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class FaqsScreenShimmer extends StatelessWidget {
  const FaqsScreenShimmer({super.key});

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
              padding: EdgeInsets.only(bottom: height(16)),
              child: Container(
                padding: EdgeInsets.all(width(16)),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerBox(
                            height: height(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: width(12)),
                        ShimmerBox(
                          width: width(24),
                          height: height(24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
