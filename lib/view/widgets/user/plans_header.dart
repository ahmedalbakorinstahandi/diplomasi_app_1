import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlansHeader extends StatelessWidget {
  final bool hasActiveSubscription;
  final bool isRenewalPending;

  const PlansHeader({
    super.key,
    this.hasActiveSubscription = true,
    this.isRenewalPending = false,
  });

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
              'خطط الاشتراك',
              style: TextStyle(
                fontSize: emp(24),
                fontWeight: FontWeight.bold,
                color: scheme.onPrimary,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          // زاوية الـ app bar: حالة الاشتراك (غير مشترك / جارٍ التجديد)
          if (!hasActiveSubscription)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width(10),
                vertical: height(6),
              ),
              decoration: BoxDecoration(
                color: scheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.onPrimary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: emp(16),
                    color: scheme.onPrimary,
                  ),
                  SizedBox(width: width(6)),
                  Text(
                    'غير مشترك حالياً',
                    style: TextStyle(
                      fontSize: emp(12),
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            )
          else if (isRenewalPending)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width(10),
                vertical: height(6),
              ),
              decoration: BoxDecoration(
                color: scheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.onPrimary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  Icon(
                    Icons.autorenew,
                    size: emp(16),
                    color: scheme.onPrimary,
                  ),
                  SizedBox(width: width(6)),
                  Text(
                    'جارٍ التجديد',
                    style: TextStyle(
                      fontSize: emp(12),
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
