import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';

class CertificatesScreenShimmer extends StatelessWidget {
  const CertificatesScreenShimmer({super.key});

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
                widthFactor: 0.5,
                child: ShimmerBox(
                  height: emp(20),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width(20)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: height(12)),
              itemBuilder: (context, index) {
                return ShimmerBox(
                  height: height(260),
                  borderRadius: BorderRadius.circular(16),
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

