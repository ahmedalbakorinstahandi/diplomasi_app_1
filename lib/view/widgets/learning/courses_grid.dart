import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/course_model.dart';
import 'package:diplomasi_app/view/widgets/learning/course_card.dart';
import 'package:flutter/material.dart';

class CoursesGrid extends StatelessWidget {
  final List<CourseModel> courses;
  final Function(CourseModel)? onCourseTap;
  final int? currentCourseId;
  final int? previousCourseId;

  const CoursesGrid({
    super.key,
    required this.courses,
    this.onCourseTap,
    this.currentCourseId,
    this.previousCourseId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width(16),
        vertical: height(10),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: width(12),
          mainAxisSpacing: height(16),
          childAspectRatio: 1,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          final isSelected = currentCourseId != null && course.id == currentCourseId;
          final isPreviousSelected = previousCourseId != null && course.id == previousCourseId;

          return CourseCard(
            course: course,
            isSelected: isSelected,
            isPreviousSelected: isPreviousSelected,
            onTap: onCourseTap != null
                ? () => onCourseTap!(course)
                : null,
          );
        },
      ),
    );
  }
}
