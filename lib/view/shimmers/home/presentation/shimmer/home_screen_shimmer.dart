import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width(14)),
        child: SizedBox(
          height: getHeight() * 0.7855,
          child: Column(
            children: [
              SizedBox(height: height(16)),
              // Title row + dropdown
              Row(
                children: [
                  Expanded(
                    child: ShimmerBox(
                      height: emp(22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(width: width(12)),
                  ShimmerBox(
                    width: width(140),
                    height: height(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              SizedBox(height: height(16)),

              // Banner
              ShimmerBox(
                height: height(90),
                borderRadius: BorderRadius.circular(16),
              ),
              SizedBox(height: height(12)),

              // Progress card
              ShimmerBox(
                height: height(110),
                borderRadius: BorderRadius.circular(16),
              ),
              SizedBox(height: height(16)),

              // Tracks list
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  separatorBuilder: (_, __) => SizedBox(height: height(12)),
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        ShimmerCircle(size: emp(48)),
                        SizedBox(width: width(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              ShimmerBox(
                                height: 14,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              SizedBox(height: 8),
                              FractionallySizedBox(
                                widthFactor: 0.7,
                                child: ShimmerBox(
                                  height: 12,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
