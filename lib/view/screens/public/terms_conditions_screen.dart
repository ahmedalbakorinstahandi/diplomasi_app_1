import 'package:diplomasi_app/controllers/public/terms_conditions_controller.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/shimmers/public/presentation/shimmer/terms_conditions_screen_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TermsConditionsControllerImp());
    return GetBuilder<TermsConditionsControllerImp>(
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text('terms_conditions'.tr)),
          body: controller.isLoading
              ? const TermsConditionsScreenShimmer()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width(20),
                    // vertical: height(20),
                  ),
                  child: Html(
                    data: controller.termsConditions,
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: scheme.onSurface,
                        // fontFamily: 'Sans_Arabic',
                      ),
                    },
                  ),
                ),
        );
      },
    );
  }
}