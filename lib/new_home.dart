import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_screen.dart';
import 'controllers/theme_controller.dart';

class NewHomePage extends StatelessWidget {
  const NewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI'),
        actions: [
          // Theme toggle button
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color:
                    themeController.isDarkMode.value
                        ? Colors.amber
                        : Colors.indigo,
              ),
              tooltip:
                  themeController.isDarkMode.value
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
              onPressed: themeController.toggleTheme,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE8F0FE),
              child: Icon(
                Icons.auto_awesome,
                size: 50,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Welcome to Gemini',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Google\'s most capable AI model',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // Use GetX navigation instead of MaterialPageRoute
                Get.to(() => const ChatScreen());
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start Chatting'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
