import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/learning/course_model.dart';
import 'package:diplomasi_app/view/shimmers/learning/presentation/shimmer/courses_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/learning/courses_grid.dart';
import 'package:diplomasi_app/view/widgets/learning/courses_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:diplomasi_app/controllers/learning/cources_controller.dart';

class CourcesScreen extends StatelessWidget {
  const CourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourcesControllerImp>(
      init: CourcesControllerImp(),
      builder: (controller) {
        // Convert courses list to CourseModel list
        final courses = controller.courses
            .map(
              (course) => CourseModel.fromJson(course as Map<String, dynamic>),
            )
            .toList();

        return MyScaffold(
          body: HandlingListDataView(
            isLoading: controller.isLoading,
            dataIsEmpty: courses.isEmpty,
            loadingWidget: const CoursesScreenShimmer(),
            child: Column(
              children: [
                // Header Section
                const CoursesHeader(),
                // Courses Grid Section
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    child: CoursesGrid(
                      courses: courses,
                      currentCourseId: controller.currentCourseId,
                      previousCourseId: controller.previousCourseId,
                      onCourseTap: (course) {
                        // Save the selected course
                        controller.selectCourse(course.id);
                        // Navigate to levels page
                        Get.toNamed(
                          AppRoutes.levels,
                          parameters: {'id': course.id.toString()},
                        );
                      },
                    ),
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
