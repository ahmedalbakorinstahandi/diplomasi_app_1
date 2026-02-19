import 'package:diplomasi_app/controllers/app_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppControllerImp());
    return GetBuilder<AppControllerImp>(
      builder: (controller) {
        final colors = context.appColors;
        final scheme = Theme.of(context).colorScheme;
        return MyScaffold(
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
              color: scheme.surface,
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
                    child: SizedBox(
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
        );
      },
    );
  }
}
