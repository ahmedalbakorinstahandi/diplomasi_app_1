final class EndPoints {
  const EndPoints._();

  static const String baseApi =
      'https://diplomasi-backend.ahmed-albakor.com/api/v1';

  static String login = "$baseApi/auth/login";
  static String register = "$baseApi/auth/register";
  static String forgotPassword = "$baseApi/auth/forgot-password";
  static String verifyOtp = "$baseApi/auth/verify-otp";
  static String resetPassword = "$baseApi/auth/reset-password";
  static String logout = "$baseApi/auth/logout";
  static String requestAccountDeletion =
      "$baseApi/auth/request-account-deletion";
  static String confirmAccountDeletion =
      "$baseApi/auth/confirm-account-deletion";

  // User Routes
  static String userMe = "$baseApi/user/me";
  static String notifications = "$baseApi/user/notifications";
  static String markAllRead = "$baseApi/user/notifications/mark-all-read";
  static String unreadCount = "$baseApi/user/notifications/unread-count";
  static String plans = "$baseApi/user/plans";
  static String billingSubscription = "$baseApi/user/billing/subscription";
  static String billingSubscriptionPurchase =
      "$baseApi/user/billing/subscription/purchase";
  static String billingSubscriptionPurchaseWithPayment =
      "$baseApi/user/billing/subscription/purchase-with-payment";
  static String billingSubscriptionCancel =
      "$baseApi/user/billing/subscription/cancel";
  static String billingSubscriptionResume =
      "$baseApi/user/billing/subscription/resume";
  static String billingSubscriptionRetryPayment =
      "$baseApi/user/billing/subscription/retry-payment";
  static String billingPaymentsVerify = "$baseApi/user/billing/payments/verify";
  static String billingPaymentMethods = "$baseApi/user/billing/payment-methods";
  static String billingPaymentMethodSetDefault =
      "$baseApi/user/billing/payment-methods/{id}/set-default";
  static String billingPaymentMethodDelete =
      "$baseApi/user/billing/payment-methods/{id}";
  static String billingInvoices = "$baseApi/user/billing/invoices";
  static String billingInvoice = "$baseApi/user/billing/invoices/{id}";
  static String billingPayments = "$baseApi/user/billing/payments";
  // static String billingInvoices = "$baseApi/user/billing/invoices";
  // static String billingInvoice = "$baseApi/user/billing/invoices/{id}";
  static String billingInvoiceDownload =
      "$baseApi/user/billing/invoices/{id}/download";
  // static String billingPayments = "$baseApi/user/billing/payments";
  static String certificates = "$baseApi/user/certificates";
  static String certificate = "$baseApi/user/certificates/{id}";
  static String certificateDownload =
      "$baseApi/user/certificates/{id}/download";
  static String certificateVerifyImage =
      "$baseApi/user/certificates/{id}/verify-image";
  static String articles = "$baseApi/user/articles";
  static String faqs = "$baseApi/user/faqs";
  static String videosUrl = "$baseApi/user/lessons/videos-url";

  // Learning Routes
  static String cource = "$baseApi/user/courses/{id}";
  static String cources = "$baseApi/user/courses";
  static String level = "$baseApi/user/levels/{id}";
  static String levels = "$baseApi/user/levels";

  static String lesson = "$baseApi/user/lessons/{id}";

  static String levelTracks = "$baseApi/user/level-tracks";

  // Lesson Routes
  static String lessonStartAttempt = "$baseApi/user/lessons/{id}/start-attempt";
  static String lessonQuestions = "$baseApi/user/lessons/{id}/questions";
  static String lessonCurrentQuestion =
      "$baseApi/user/lessons/{id}/attempts/{attemptId}/current-question";
  static String lessonSubmitAnswer =
      "$baseApi/user/lessons/{id}/attempts/{attemptId}/submit-answer";
  static String lessonFinishAttempt =
      "$baseApi/user/lessons/{id}/attempts/{attemptId}/finish";
  static String lessonMarkVideoWatched =
      "$baseApi/user/lessons/{id}/attempts/{attemptId}/mark-video-watched";

  // Glossary Routes
  static String glossaryTerms = "$baseApi/user/glossary-terms";
  static String glossaryTerm = "$baseApi/user/glossary-terms/{id}";

  // Scenario Routes
  static String scenario = "$baseApi/user/scenarios/{id}";
  static String scenarioStartAttempt =
      "$baseApi/user/scenarios/{id}/start-attempt";
  static String scenarioCurrentQuestion =
      "$baseApi/user/scenarios/{id}/attempts/{attemptId}/current-question";
  static String scenarioSubmitAnswer = "$baseApi/user/scenarios/submit-answer";
  static String scenarioFinishAttempt =
      "$baseApi/user/scenarios/{id}/attempts/{attemptId}/finish";
  static String scenarioMarkDescriptionRead =
      "$baseApi/user/scenarios/{id}/attempts/{attemptId}/mark-description-read";

  // General Routes
  static String uploadImage = "$baseApi/general/upload-image";
  static String verifyCertificate =
      "$baseApi/general/certificates/verify/{certificateCode}";

  // settings
  static String setting = "$baseApi/general/settings/{idOrKey}";
}
