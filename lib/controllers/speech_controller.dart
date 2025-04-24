import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  // Initialize speech recognition with permission handling
  Future<void> initSpeech() async {
    // Request microphone permission
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      debugPrint('Microphone permission granted');
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech recognition error: ${errorNotification.errorMsg}');
          isListening.value = false;
        },
      );
      debugPrint('Speech recognition available: $available');
    } else {
      debugPrint('Microphone permission denied');
      Get.snackbar(
        'Permission Error',
        'Microphone permission is required for speech recognition',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Start or stop speech recognition
  Future<bool> toggleListening() async {
    // Check microphone permission first
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Error',
          'Microphone permission is required for speech recognition',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }

    if (!isListening.value) {
      // Re-initialize speech recognition each time to avoid issues
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          debugPrint('Speech error: ${errorNotification.errorMsg}');
          isListening.value = false;
          Get.snackbar(
            'Recognition Error',
            'Error: ${errorNotification.errorMsg}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
      );

      if (available) {
        isListening.value = true;
        recognizedText.value = '';

        try {
          debugPrint('Starting speech recognition...');
          await _speech.listen(
            onResult: (result) {
              debugPrint('Got speech result: ${result.recognizedWords}');
              recognizedText.value = result.recognizedWords;
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 5),
            partialResults: true,
            cancelOnError: false,
          );
          return true;
        } catch (e) {
          debugPrint('Error during speech recognition: $e');
          isListening.value = false;
          Get.snackbar(
            'Recognition Error',
            'Speech recognition error: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        debugPrint('Speech recognition not available');
        Get.snackbar(
          'Recognition Error',
          'Speech recognition not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } else {
      debugPrint('Stopping speech recognition...');
      await _speech.stop();
      isListening.value = false;
      return true;
    }
  }

  // Clear recognized text
  void clearRecognizedText() {
    recognizedText.value = '';
  }

  // Stop speech recognition
  Future<void> stopListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
    }
  }
}
