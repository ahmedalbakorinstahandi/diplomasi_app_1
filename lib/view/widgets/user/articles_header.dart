import 'package:diplomasi_app/controllers/user/articles_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticlesHeader extends StatelessWidget {
  const ArticlesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final scheme = Theme.of(context).colorScheme;

    return GetBuilder<ArticlesControllerImp>(
      builder: (controller) {
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
                  Expanded(
                    child: controller.isSearchMode
                        ? _buildSearchField(context, controller, scheme)
                        : Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'المقالات',
                                  style: TextStyle(
                                    fontSize: emp(24),
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  controller.toggleSearchMode();
                                },
                                child: Icon(
                                  Icons.search,
                                  color: scheme.onPrimary,
                                  size: width(24),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              if (!controller.isSearchMode) ...[
                SizedBox(height: height(12)),
                Text(
                  'اقرأ آخر المقالات والتحديثات...',
                  style: TextStyle(
                    fontSize: emp(16),
                    color: scheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    ArticlesControllerImp controller,
    ColorScheme scheme,
  ) {
    final colors = context.appColors;

    return GetBuilder<ArticlesControllerImp>(
      builder: (ctrl) {
        return Container(
          height: height(60),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(width(16)),
            border: Border.all(color: colors.border.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: width(16)),
              // Search Icon
              Icon(
                Icons.search_rounded,
                color: colors.textMuted,
                size: width(22),
              ),
              SizedBox(width: width(12)),
              // Text Field
              Expanded(
                child: TextField(
                  controller: ctrl.searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: emp(16),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث في المقالات، العناوين، أو المؤلفين...',
                    hintStyle: TextStyle(
                      color: colors.textMuted,
                      fontSize: emp(14),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: height(12)),
                  ),
                  onChanged: (value) {
                    ctrl.onSearchChanged(value);
                  },
                  textDirection: TextDirection.rtl,
                ),
              ),
              // Clear Button
              if (ctrl.searchController.text.isNotEmpty) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ctrl.searchController.clear();
                      ctrl.clearSearch();
                    },
                    borderRadius: BorderRadius.circular(width(8)),
                    child: Container(
                      padding: EdgeInsets.all(width(8)),
                      child: Icon(
                        Icons.close_rounded,
                        color: colors.textMuted,
                        size: width(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width(4)),
              ],
              // Close Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ctrl.toggleSearchMode();
                  },
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(width(16)),
                    bottomRight: Radius.circular(width(16)),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width(12),
                      vertical: height(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.textSecondary,
                      size: width(18),
                    ),
                  ),
                ),
              ),
              SizedBox(width: width(4)),
            ],
          ),
        );
      },
    );
  }
}
