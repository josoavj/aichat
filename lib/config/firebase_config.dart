import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_test/firebase_options.dart';

class FirebaseConfig {
  /// Initialiser Firebase avec les options appropriées à la plateforme
  static Future<void> initialize() async {
    try {
      // Essayer d'initialiser Firebase pour toutes les plateformes
      // Pour Linux/Web, utiliser une configuration de développement
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
      } else if (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // Pour le développement desktop, essayer d'initialiser avec une config test
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } catch (e) {
          print('ℹ️  Firebase non configuré pour cette plateforme: $e');
          // Continuer sans Firebase pour le développement
          return;
        }
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      print('✓ Firebase initialisé avec succès');
    } catch (e) {
      print('✗ Erreur lors de l\'initialisation de Firebase: $e');
      rethrow;
    }
  }
}
