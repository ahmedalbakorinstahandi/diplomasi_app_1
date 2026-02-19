import 'package:diplomasi_app/controllers/public/privacy_policy_controller.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/shimmers/public/presentation/shimmer/privacy_policy_screen_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PrivacyPolicyControllerImp());
    return GetBuilder<PrivacyPolicyControllerImp>(
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text('privacy_policy'.tr)),
          body: controller.isLoading
              ? const PrivacyPolicyScreenShimmer()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width(20),
                    // vertical: height(20),
                  ),
                  child: Html(
                    data: controller.privacyPolicy,
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
