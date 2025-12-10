import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_test/firebase_options.dart';

class FirebaseConfig {
  /// Initialiser Firebase avec les options appropriées à la plateforme
  static Future<void> initialize() async {
    try {
      // Firebase n'est pas configuré pour Linux et Web (mode debug)
      if (kIsWeb ||
          (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        print('ℹ️  Firebase non configuré pour cette plateforme');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✓ Firebase initialisé avec succès');
    } catch (e) {
      print('✗ Erreur lors de l\'initialisation de Firebase: $e');
      rethrow;
    }
  }
}
