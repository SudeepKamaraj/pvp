import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/views/splash_screen.dart';
import 'core/bindings/main_binding.dart';
import 'firebase_options.dart';
import 'scripts/admin_seed.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/i18n/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Seed Admin User
  await seedAdminUser();

  final prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('language_code');
  
  runApp(MyApp(initialLocale: languageCode != null ? Locale(languageCode) : const Locale('en')));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PVP Traders',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      home: const SplashScreen(),
      initialBinding: MainBinding(),
    );
  }
}
