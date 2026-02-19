import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: getWidth(),
      height: height(190),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + height(20),
        left: width(20),
        right: width(20),
        bottom: height(30),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
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
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(Icons.arrow_back, color: scheme.onPrimary),
                ),
              ),

              SizedBox(width: width(12)),

              Text(
                'تعديل الملف الشخصي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: emp(20),
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
