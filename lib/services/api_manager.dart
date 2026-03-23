import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ai_test/services/logger_service.dart';

/// Gère le stockage sécurisé et l'accès à la clé API avec validation
class ApiManager {
  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const int _minApiKeyLength = 20;
  static const _secureStorage = FlutterSecureStorage();

  /// Sauvegarde la clé API de manière sécurisée
  static Future<void> saveApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();

    if (!isValidApiKey(trimmedKey)) {
      AppLogger.warning('Tentative de sauvegarde avec clé API invalide');
      throw ApiManagerException(
        'Clé API invalide. Veuillez vérifier la clé et réessayer.',
      );
    }

    try {
      await _secureStorage.write(
        key: _apiKeyStorageKey,
        value: trimmedKey,
      );
      AppLogger.info('Clé API sauvegardée avec succès');
    } catch (e) {
      AppLogger.error('Erreur lors de la sauvegarde de la clé API', e);
      throw ApiManagerException(
        'Erreur lors de la sauvegarde de la clé APIː $e',
      );
    }
  }

  /// Récupère la clé API stockée de manière sécurisée
  static Future<String?> getApiKey() async {
    try {
      final apiKey = await _secureStorage.read(
        key: _apiKeyStorageKey,
      );
      if (apiKey != null) {
        AppLogger.debug('Clé API récupérée avec succès');
      }
      return apiKey;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération de la clé API', e);
      throw ApiManagerException(
        'Erreur lors de la récupération de la clé APIː $e',
      );
    }
  }

  /// Supprime la clé API stockée de manière sécurisée
  static Future<void> deleteApiKey() async {
    try {
      await _secureStorage.delete(
        key: _apiKeyStorageKey,
      );
      AppLogger.info('Clé API supprimée avec succès');
    } catch (e) {
      AppLogger.error('Erreur lors de la suppression de la clé API', e);
      throw ApiManagerException(
        'Erreur lors de la suppression de la clé APIː $e',
      );
    }
  }

  /// Valide une clé API
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty) return false;
    if (apiKey.length < _minApiKeyLength) return false;
    // Vérifier que la clé ne contient que des caractères alphanumériques et tirets
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(apiKey)) return false;
    return true;
  }
}

/// Exception personnalisée pour les erreurs de gestion d'API
class ApiManagerException implements Exception {
  final String message;

  ApiManagerException(this.message);

  @override
  String toString() => message;
}
