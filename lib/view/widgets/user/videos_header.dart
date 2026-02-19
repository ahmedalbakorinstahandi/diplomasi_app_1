import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideosHeader extends StatelessWidget {
  const VideosHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: getWidth(),
      padding: EdgeInsets.only(
        top: statusBarHeight + height(20),
        left: width(20),
        right: width(20),
        bottom: height(30),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: scheme.onPrimary,
                ),
              ),
              SizedBox(width: width(12)),
              Text(
                'مكتبة الفيديوهات',
                style: TextStyle(
                  fontSize: emp(24),
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: height(12)),
          Text(
            'شاهد جميع الفيديوهات التعليمية...',
            style: TextStyle(
              fontSize: emp(16),
              color: scheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
