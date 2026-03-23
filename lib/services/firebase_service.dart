import 'package:ai_test/services/firebase_auth_service.dart';
import 'package:ai_test/services/firestore_service.dart';
import 'package:ai_test/services/firebase_storage_service.dart';
import 'package:ai_test/services/logger_service.dart';

/// Classe centrale pour accéder à tous les services Firebase
/// Pattern Singleton pour assurer une instance unique
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  // Services Firebase
  late final FirebaseAuthService auth;
  late final FirestoreService firestore;
  late final FirebaseStorageService storage;

  // Constructeur privé
  FirebaseService._internal() {
    auth = FirebaseAuthService();
    firestore = FirestoreService();
    storage = FirebaseStorageService();
  }

  // Factory constructor pour obtenir l'instance singleton
  factory FirebaseService() {
    return _instance;
  }

  /// Initialiser tous les services
  void initialize() {
    // Les services sont déjà initialisés via le constructeur
    AppLogger.info('Services Firebase initialisés');
  }

  /// Déconnecter et nettoyer
  Future<void> dispose() async {
    try {
      // Ici vous pouvez ajouter le nettoyage si nécessaire
      AppLogger.info('Services Firebase fermés');
    } catch (e) {
      AppLogger.error('Erreur lors de la fermeture des services', e);
    }
  }
}

/// Alias pour accès facile
final firebaseService = FirebaseService();
