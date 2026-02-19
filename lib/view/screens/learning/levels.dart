import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/levels_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/auth/custom_button.dart';
import 'package:diplomasi_app/view/widgets/learning/levels_header.dart';
import 'package:diplomasi_app/view/widgets/learning/levels_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/controllers/learning/levels_controller.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LevelsControllerImp>(
      init: LevelsControllerImp(),
      builder: (controller) {
        // Convert levels list to LevelModel list
        final levels = controller.levels
            .map((level) => LevelModel.fromJson(level as Map<String, dynamic>))
            .toList();

        return MyScaffold(
          body: Column(
            children: [
              // Header Section
              const LevelsHeader(),
              // Levels List Section
              HandlingListDataView(
                isLoading: controller.isLoading,
                dataIsEmpty: levels.isEmpty,
                loadingWidget: const LevelsScreenShimmer(),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: width(16)),
                  children: [
                    LevelsList(
                      levels: levels,
                      selectedLevelId: controller.selectedLevelId,
                      onLevelTap: (level) {
                        controller.selectLevel(level.id);
                        // Handle level tap - navigate to level details or content
                      },
                    ),

                    SizedBox(height: height(20)),

                    CustomButton(
                      text: 'ابدأ التعلم',
                      onPressed: controller.startLearning,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
