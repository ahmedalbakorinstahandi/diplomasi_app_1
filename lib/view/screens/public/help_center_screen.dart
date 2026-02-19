import 'package:diplomasi_app/controllers/public/help_center_controller.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/view/shimmers/public/presentation/shimmer/help_center_screen_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HelpCenterControllerImp());
    return GetBuilder<HelpCenterControllerImp>(
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text('help_center'.tr)),
          body: controller.isLoading
              ? const HelpCenterScreenShimmer()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width(20),
                    // vertical: height(20),
                  ),
                  child: Html(
                    data: controller.helpCenter,
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
