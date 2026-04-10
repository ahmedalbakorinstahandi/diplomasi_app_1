import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/view/widgets/general/account_upgrade_sheet.dart';
import 'package:diplomasi_app/view/widgets/general/notification_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isGuest = currentAccountState == 'guest';

    Future<void> handleProfileTap() async {
      if (isGuest) {
        await AccountUpgradeSheet.show(
          context: context,
          title: 'أنشئ حسابك للمتابعة',
          description:
              'للوصول لملفك الشخصي ومزامنة بياناتك، سجّل دخولك أو انضم الآن.',
        );
        return;
      }
      Get.toNamed(AppRoutes.editProfile);
    }

    return Container(
      width: getWidth(),
      padding: EdgeInsets.only(
        top: statusBarHeight + height(20),
        left: width(20),
        right: width(20),
        bottom: height(20),
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
          // Top bar with book icon, points, and profile
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile picture
              InkWell(
                onTap: handleProfileTap,
                child: Container(
                  width: width(40),
                  height: width(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.onPrimary.withOpacity(0.3),
                    border: Border.all(color: scheme.onPrimary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: _avatarUrlValid(user?.avatar)
                        ? CachedNetworkImage(
                            imageUrl: user!.avatar!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: scheme.onPrimary,
                              size: emp(24),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: scheme.onPrimary,
                            size: emp(24),
                          ),
                  ),
                ),
              ),
              SizedBox(width: width(16)),
              InkWell(
                onTap: handleProfileTap,
                child: Text(
                  user?.firstName ?? 'متعلم',
                  style: TextStyle(
                    fontSize: emp(16),
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(width: width(16)),

              // // Book icon and points
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: width(12),
              //     vertical: height(8),
              //   ),
              //   decoration: BoxDecoration(
              //     color: colors.surfaceCard,
              //     borderRadius: BorderRadius.circular(52),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       MySvgIcon(
              //         path: Assets.icons.svg.fireDepartment,
              //         size: emp(20),
              //         color: scheme.primary,
              //       ),
              //       SizedBox(width: width(8)),
              //       Text(
              //         '10 نقطة',
              //         style: TextStyle(
              //           fontSize: emp(14),
              //           fontWeight: FontWeight.w400,
              //           color: colors.textPrimary,
              //           height: 17 / 14.0156,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Spacer(),
              NotificationButton(),
              SizedBox(width: width(8)),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.cources);
                },
                child: Container(
                  width: width(40),
                  height: height(40),
                  decoration: BoxDecoration(
                    color: colors.surfaceCard,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: MySvgIcon(
                      path: Assets.icons.svg.book,
                      size: emp(24),
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _avatarUrlValid(String? url) {
    final u = url?.trim();
    return u != null && u.isNotEmpty;
  }
}
