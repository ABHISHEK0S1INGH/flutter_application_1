import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'new_home.dart';
import 'controllers/gemini_controller.dart';
import 'controllers/speech_controller.dart';
import 'controllers/theme_controller.dart';

void main() {
  // Add error configuration to handle framework issues
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Return a custom error widget or fallback
    return Material(
      color: Colors.red.withOpacity(0.1),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('An error occurred: ${details.exception}'),
        ),
      ),
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(GeminiController());
    Get.put(SpeechController());
    Get.put(ThemeController());

    final ThemeController themeController = Get.find();

    return Obx(
      () => GetMaterialApp(
        title: 'Gemini Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8), // Google blue
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            iconTheme: IconThemeData(color: Color(0xFF1A73E8)),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8), // Google blue
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        ),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        home: const NewHomePage(),
      ),
    );
  }
}
