import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class EditProfileScreenShimmer extends StatelessWidget {
  const EditProfileScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: true,
      child: SingleChildScrollView(
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
                  widthFactor: 0.55,
                  child: ShimmerBox(
                    height: emp(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: height(20)),
            ShimmerCircle(size: emp(92)),
            SizedBox(height: height(24)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width(14)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(
                          height: height(76),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      SizedBox(width: width(12)),
                      Expanded(
                        child: ShimmerBox(
                          height: height(76),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height(12)),
                  ShimmerBox(
                    height: height(76),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: height(12)),
                  ShimmerBox(
                    height: height(76),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: height(18)),
                  ShimmerBox(
                    height: height(54),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  SizedBox(height: height(24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

