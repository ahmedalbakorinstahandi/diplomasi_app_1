abstract class StorageKeys {
  static String get step => 'step';
  static String get user => 'user';
  static String get profile => 'profile';
  static String get homeData => 'home_data';
  static String get accessToken => 'access_token';
  static String get accountState => 'account_state';
  static String get fcmToken => 'fcm_token';
  static String get notificationPromptShownAt => 'notification_prompt_shown_at';
  static String get start => 'start';
  static String get readNotificationsByGuest => 'read_notifications_by_guest';
  static String get courseId => 'course_id';
  static String get levelId => 'level_id';
  static String get lessonAttemptId => 'lesson_attempt_id';
  static String get themeMode => 'theme_mode'; // system | light | dark
  static String get subscriptionState => 'subscription_state';
  static String get lastUpdateSuggestionAt => 'last_update_suggestion_at';
  /// Cached `courses_mode` summary from GET /user/me (app).
  static String get appCoursesCatalog => 'app_courses_catalog';
}
