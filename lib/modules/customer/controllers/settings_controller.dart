import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  var pushNotifications = true.obs;
  var selectedLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredLanguage();
  }

  void _loadStoredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'en';
    if (code == 'en') selectedLanguage.value = 'English';
    else if (code == 'ta') selectedLanguage.value = 'Tamil';
    else if (code == 'hi') selectedLanguage.value = 'Hindi';
  }

  void changeLanguage(String lang) async {
    selectedLanguage.value = lang;
    String code = 'en';
    if (lang == 'Tamil') code = 'ta';
    else if (lang == 'Hindi') code = 'hi';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    
    Get.updateLocale(Locale(code));
    // Get.snackbar("Language Updated", "Language changed to $lang");
  }
}
