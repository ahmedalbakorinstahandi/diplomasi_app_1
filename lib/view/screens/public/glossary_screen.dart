import 'package:diplomasi_app/controllers/public/glossary_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/public/presentation/shimmer/glossary_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_text_field.dart';
import 'package:diplomasi_app/view/widgets/glossary/glossary_header.dart';
import 'package:diplomasi_app/view/widgets/glossary/glossary_term_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GlossaryControllerImp());
    return GetBuilder<GlossaryControllerImp>(
      init: GlossaryControllerImp(),
      builder: (controller) {
        return MyScaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.getGlossaryTerms();
            },
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                const GlossaryHeader(),
                SizedBox(height: height(8)),
                // Search Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width(14)),
                  child: CustomTextField(
                    hintText: 'ابحث عن مصطلح...',
                    iconPath: Assets.icons.svg.search,
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.filterTerms(value);
                    },
                  ),
                ),
                SizedBox(height: height(16)),
                HandlingListDataView(
                  isLoading: controller.isLoading,
                  dataIsEmpty: controller.filteredTerms.isEmpty,
                  emptyMessage: 'لا توجد مصطلحات',
                  loadingWidget: const GlossaryScreenShimmer(),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: width(14)),
                        height: getHeight() * 0.65,
                        child: Column(
                          children: [
                            // Terms List
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: controller.filteredTerms.length,
                                itemBuilder: (context, index) {
                                  final term = controller.filteredTerms[index];
                                  return GlossaryTermCard(
                                    key: ValueKey('glossary_term_${term.id}'),
                                    term: term,
                                    searchQuery:
                                        controller.searchQuery.isNotEmpty
                                        ? controller.searchQuery
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
