import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/profile/profile_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/view/widgets/general/account_upgrade_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return GetBuilder<ProfileControllerImp>(
      init: ProfileControllerImp(),
      builder: (controller) {
        final user = getUserData();
        final isGuest = currentAccountState == 'guest';

        Future<void> handleIdentityTap() async {
          if (isGuest) {
            await AccountUpgradeSheet.show(
              context: context,
              title: 'احفظ تقدمك بحساب حقيقي',
              description:
                  'أنشئ حسابًا أو سجّل دخولك للمتابعة من أي جهاز والوصول لكل ميزات الحساب.',
            );
            return;
          }

          Get.toNamed(AppRoutes.editProfile);
        }
        return Positioned(
          top: height(90),
          child: Column(
            children: [
              // Profile Picture with Gold Border
              InkWell(
                borderRadius: BorderRadius.circular(150),
                onTap: handleIdentityTap,
                child: Container(
                  width: width(120),
                  height: width(120),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                    border: Border.all(color: colors.highlight, width: 6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: _avatarUrlValid(user?.avatar)
                        ? CachedNetworkImage(
                            imageUrl: user!.avatar!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                _buildPlaceholder(colors),
                          )
                        : _buildPlaceholder(colors),
                  ),
                ),
              ),
              SizedBox(height: height(16)),
              // User Name
              InkWell(
                onTap: handleIdentityTap,
                child: Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                  style: TextStyle(
                    fontSize: emp(16),
                    fontWeight: FontWeight.w400,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: height(8)),
              // Email
              InkWell(
                onTap: handleIdentityTap,
                child: Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: emp(16),
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _avatarUrlValid(String? url) {
    final u = url?.trim();
    return u != null && u.isNotEmpty;
  }

  static Widget _buildPlaceholder(AppColors colors) {
    return Container(
      color: colors.border,
      child: Icon(
        Icons.person,
        color: colors.textSecondary,
        size: emp(40),
      ),
    );
  }
}
