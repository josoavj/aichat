import 'package:shared_preferences/shared_preferences.dart';

/// Gère le stockage et l'accès à la clé API avec validation
class ApiManager {
  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const int _minApiKeyLength = 20;

  /// Sauvegarde la clé API et initialise le service
  static Future<void> saveApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();

    if (!isValidApiKey(trimmedKey)) {
      throw ApiManagerException(
        'Clé API invalide. Veuillez vérifier la clé et réessayer.',
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyStorageKey, trimmedKey);
    } catch (e) {
      throw ApiManagerException(
        'Erreur lors de la sauvegarde de la clé APIː $e',
      );
    }
  }

  /// Récupère la clé API stockée
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyStorageKey);
    } catch (e) {
      throw ApiManagerException(
        'Erreur lors de la récupération de la clé APIː $e',
      );
    }
  }

  /// Supprime la clé API stockée
  static Future<void> deleteApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyStorageKey);
    } catch (e) {
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
