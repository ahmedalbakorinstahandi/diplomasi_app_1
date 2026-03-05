import 'package:diplomasi_app/controllers/app_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({super.key});

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final colors = Get.theme.extension<AppColors>() ?? AppColors.light;
    final scheme = Get.theme.colorScheme;
    final result = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.exit_to_app, color: scheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'exit_app'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'exit_app_confirmation'.tr,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(result: false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colors.borderStrong),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'exit_app'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AppControllerImp());
    return GetBuilder<AppControllerImp>(
      builder: (controller) {
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (controller.pageIndex == 1 || controller.pageIndex == 2) {
              controller.goToHome();
            } else {
              final shouldExit = await _showExitConfirmation(context);
              if (shouldExit && context.mounted) {
                SystemNavigator.pop();
              }
            }
          },
          child: MyScaffold(
            body: SizedBox(
              height: getHeight(),
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: (index) {
                  controller.onPageChanged(index);
                },
                itemBuilder: (context, index) {
                  return controller.pages[index]['screen'];
                },
              ),
            ),

            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: width(12)),
              height: getHeight() * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...List.generate(controller.pages.length, (index) {
                    bool selected = controller.pageIndex == index;

                    String icon = controller.pages[index]['icon'];

                    String name = "${controller.pages[index]['name']}".tr;

                    Color nameColor = selected
                        ? scheme.primary
                        : colors.textSecondary;
                    return GestureDetector(
                      onTap: () {
                        controller.changePage(index);
                      },
                      child: Container(
                        color: colors.surface,
                        width: getWidth() / controller.pages.length - width(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              icon,
                              height: width(28),
                              color: nameColor,
                            ),
                            SizedBox(height: height(8)),
                            Text(
                              name,
                              style: TextStyle(
                                color: nameColor,
                                fontWeight: FontWeight.w400,
                                fontSize: width(14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
