import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // Observable boolean to track dark mode status
  final RxBool isDarkMode = false.obs;

  // Key for storing theme preference
  static const String _themePreferenceKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  // Toggle between light and dark theme
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool(_themePreferenceKey) ?? false;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  // Save current theme preference
  Future<void> _saveThemePreference() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, isDarkMode.value);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }
}
