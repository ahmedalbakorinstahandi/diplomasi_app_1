import 'dart:async';

import 'package:diplomasi_app/core/bindings/initialbindings.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/localization/translation.dart';
import 'package:diplomasi_app/data/resource/remote/user/user_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional: no bundled .env in some builds
  }

  // Ensure Android system bars stay visible app-wide (can be altered by video fullscreen).
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

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
  try {
    await pushNotificationService.init();
  } catch (_) {
    // Messaging may be unavailable in some environments; app should still run.
  }

  // Theme controller needs SharedPreferences (services) ready.
  Get.put(ThemeControllerImp(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _heartbeatDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _heartbeatDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleHeartbeat();
    }
  }

  void _scheduleHeartbeat() {
    _heartbeatDebounce?.cancel();
    _heartbeatDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!isUserLoggedIn) return;
      final token = Shared.getValue(StorageKeys.accessToken);
      if (token == null || token.toString().trim().isEmpty) return;
      UserData().sendHeartbeat();
    });
  }

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
