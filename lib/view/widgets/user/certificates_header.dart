import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CertificatesHeader extends StatelessWidget {
  const CertificatesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + height(20),
        bottom: height(20),
        left: width(20),
        right: width(20),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Back button
          InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: scheme.onPrimary,
            ),
          ),
          SizedBox(width: width(12)),
          // Title
          Expanded(
            child: Text(
              'شهاداتي',
              style: TextStyle(
                fontSize: emp(24),
                fontWeight: FontWeight.bold,
                color: scheme.onPrimary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
