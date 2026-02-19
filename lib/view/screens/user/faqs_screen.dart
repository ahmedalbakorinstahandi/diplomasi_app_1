import 'package:diplomasi_app/controllers/user/faqs_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/faq_model.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/faqs_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/faq_card.dart';
import 'package:diplomasi_app/view/widgets/user/faqs_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FaqsControllerImp());
    return GetBuilder<FaqsControllerImp>(
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              // Header Section
              const FaqsHeader(),

              SizedBox(height: height(12)),

              SizedBox(height: height(12)),

              // FAQs List Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.getFaqs(reload: true);
                  },
                  child: HandlingListDataView(
                    isLoading: controller.isLoading,
                    dataIsEmpty: controller.filteredFaqs.isEmpty,
                    emptyMessage: 'لا توجد أسئلة شائعة',
                    loadingWidget: const FaqsScreenShimmer(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller.faqsScrollController,
                      padding: EdgeInsets.symmetric(horizontal: width(16)),
                      children: [
                        ...controller.filteredFaqs.asMap().entries.map((entry) {
                          final faq = FaqModel.fromJson(entry.value);
                          return FaqCard(
                            key: ValueKey('faq_${faq.id}'),
                            faq: faq,
                            searchQuery: controller.searchQuery.isNotEmpty
                                ? controller.searchQuery
                                : null,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
