import 'package:diplomasi_app/core/bindings/initialbindings.dart';
import 'package:diplomasi_app/core/localization/translation.dart';
import 'package:diplomasi_app/core/services/notification_navigation_service.dart';
import 'package:diplomasi_app/core/services/push_notification_service.dart';
import 'package:diplomasi_app/core/services/services.dart';
import 'package:diplomasi_app/core/theme/app_theme.dart';
import 'package:diplomasi_app/controllers/theme/theme_controller.dart';
import 'package:diplomasi_app/routes/get_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // التطبيق يبدأ بالطول؛ الفيديو ينتقل للعرض عند الملء (من داخل مشغّل الفيديو)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize all app services
  await MyServices.initialServices();
  Get.put(NotificationNavigationService(), permanent: true);
  final pushNotificationService = Get.put(
    PushNotificationService(),
    permanent: true,
  );
  //await pushNotificationService.init();

  // Theme controller needs SharedPreferences (services) ready.
  Get.put(ThemeControllerImp(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeControllerImp>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diplomasi App',
      locale: Locale('ar'),
      translations: MyTranslation(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: MyTranslation.languages.keys
          .map((lang) => Locale(lang))
          .toList(),
      initialBinding: InitialBindings(),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeController.themeMode,
      getPages: getPages,
    );
  }
}
