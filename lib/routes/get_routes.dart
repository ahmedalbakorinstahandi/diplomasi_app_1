import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/view/screens/auth/login.dart';
import 'package:diplomasi_app/view/screens/auth/register.dart';
import 'package:diplomasi_app/view/screens/auth/forgot_password.dart';
import 'package:diplomasi_app/view/screens/auth/verify_code.dart';
import 'package:diplomasi_app/view/screens/auth/reset_password.dart';
import 'package:diplomasi_app/view/screens/auth/success.dart';
import 'package:diplomasi_app/view/screens/app.dart';
import 'package:diplomasi_app/view/screens/learning/cources.dart';
import 'package:diplomasi_app/view/screens/learning/levels.dart';
import 'package:diplomasi_app/view/screens/learning/lesson_screen.dart';
import 'package:diplomasi_app/view/screens/learning/lesson_questions_screen.dart';
import 'package:diplomasi_app/view/screens/learning/scenario_questions_screen.dart';
import 'package:diplomasi_app/view/screens/public/onboarding.dart';
import 'package:diplomasi_app/view/screens/public/privacy_policy.dart';
import 'package:diplomasi_app/view/screens/public/help_center_screen.dart';
import 'package:diplomasi_app/view/screens/public/terms_conditions_screen.dart';
import 'package:diplomasi_app/view/screens/public/splash_screen.dart';
import 'package:diplomasi_app/view/screens/profile/edit_profile.dart';
import 'package:diplomasi_app/view/screens/profile/change_password.dart';
import 'package:diplomasi_app/view/screens/user/notifications_screen.dart';
import 'package:diplomasi_app/view/screens/user/plans_screen.dart';
import 'package:diplomasi_app/view/screens/user/certificates_screen.dart';
import 'package:diplomasi_app/view/screens/user/certificate_detail_screen.dart';
import 'package:diplomasi_app/view/screens/user/articles_screen.dart';
import 'package:diplomasi_app/view/screens/user/article_details_screen.dart';
import 'package:diplomasi_app/view/screens/user/billing_history_screen.dart';
import 'package:diplomasi_app/view/screens/user/faqs_screen.dart';
import 'package:diplomasi_app/view/screens/user/videos_screen.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(name: '/', page: () => const SplashScreenScreen()),
  GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
  GetPage(name: AppRoutes.splash, page: () => const SplashScreenScreen()),
  GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
  GetPage(
    name: AppRoutes.forgotPassword,
    page: () => const ForgotPasswordScreen(),
  ),
  GetPage(name: AppRoutes.verifyCode, page: () => const VerifyCodeScreen()),
  GetPage(
    name: AppRoutes.resetPassword,
    page: () => const ResetPasswordScreen(),
  ),
  GetPage(name: AppRoutes.authSuccess, page: () => const SuccessScreen()),
  GetPage(name: AppRoutes.app, page: () => const AppScreen()),

  // Learning Routes
  GetPage(
    name: AppRoutes.cources,
    page: () => const CourcesScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.levels,
    page: () {
      return const LevelsScreen();
    },
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.lesson,
    page: () => const LessonScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.lessonQuestions,
    page: () => const LessonQuestionsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.scenarioQuestions,
    page: () => const ScenarioQuestionsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  // Profile Routes
  GetPage(
    name: AppRoutes.editProfile,
    page: () => const EditProfileScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.changePassword,
    page: () => const ChangePasswordScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  // User Routes
  GetPage(
    name: AppRoutes.notifications,
    page: () => const NotificationsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.plans,
    page: () => const PlansScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.certificates,
    page: () => const CertificatesScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.certificateDetail,
    page: () => const CertificateDetailScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.articles,
    page: () => const ArticlesScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.articleDetails,
    page: () => const ArticleDetailsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.faqs,
    page: () => const FaqsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.videos,
    page: () => const VideosScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.billingHistory,
    page: () => const BillingHistoryScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),

  GetPage(
    name: AppRoutes.privacyPolicy,
    page: () => const PrivacyPolicyScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.helpCenter,
    page: () => const HelpCenterScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.termsConditions,
    page: () => const TermsConditionsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
];
