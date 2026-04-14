/// Parsed `courses_mode` from GET /user/me (app context).
class CoursesModePayload {
  CoursesModePayload({
    required this.totalPublishedCourses,
    required this.hasSingleCourse,
    this.singleCourseId,
    this.singleCourseFirstLevelId,
  });

  final int totalPublishedCourses;
  final bool hasSingleCourse;
  final int? singleCourseId;
  final int? singleCourseFirstLevelId;

  static CoursesModePayload? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final total = m['total_published_courses'];
    final hasSingle = m['has_single_course'];
    if (total is! num || hasSingle is! bool) return null;
    int? sid;
    final rawSid = m['single_course_id'];
    if (rawSid is num) sid = rawSid.toInt();

    int? lid;
    final rawLid = m['single_course_first_level_id'];
    if (rawLid is num) lid = rawLid.toInt();

    return CoursesModePayload(
      totalPublishedCourses: total.toInt(),
      hasSingleCourse: hasSingle,
      singleCourseId: sid,
      singleCourseFirstLevelId: lid,
    );
  }
}
