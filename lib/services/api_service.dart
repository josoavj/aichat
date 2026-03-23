import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_test/services/logger_service.dart';

/// Service pour gérer l'API Generative AI
class ApiService {
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

  // Configuration
  static const Duration _apiTimeout = Duration(seconds: 30);

  // Paramètres de sécurité
  static final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
  ];

  /// Initialise le service avec une clé API
  void initialize(String apiKey) {
    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        safetySettings: safetySettings,
      );
      _chat = _model.startChat(history: []);
      _isInitialized = true;
      AppLogger.info('ApiService initialisé avec succès');
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation d\'ApiService', e);
      throw ApiServiceException('Erreur lors de l\'initialisation: $e');
    }
  }

  /// Vérifie si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Envoie un message et retourne la réponse avec timeout
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      final error =
          'Service non initialisé. Initialisez d\'abord avec initialize()';
      AppLogger.error(error, null);
      throw ApiServiceException(error);
    }

    if (message.trim().isEmpty) {
      final error = 'Le message ne peut pas être vide';
      AppLogger.warning(error);
      throw ApiServiceException(error);
    }

    try {
      AppLogger.debug(
          'Envoi du message à l\'API Gemini: ${message.substring(0, 50)}...');
      final userMessage = Content.text(message.trim());

      // Appel API avec timeout de sécurité
      final response = await _chat.sendMessage(userMessage).timeout(
        _apiTimeout,
        onTimeout: () {
          AppLogger.error('Timeout de l\'API Gemini après $_apiTimeout', null);
          throw TimeoutException(
              'L\'API Gemini a mis trop de temps à répondre');
        },
      );

      if (response.candidates.isEmpty) {
        final error = 'Aucune réponse valide de l\'IA reçue.';
        AppLogger.warning(error);
        throw ApiServiceException(error);
      }

      final aiResponseText = response.candidates.first.content.parts
          .whereType<TextPart>()
          .map<String>((e) => e.text)
          .join('');

      if (aiResponseText.isEmpty) {
        final error = 'La réponse de l\'IA est vide';
        AppLogger.warning(error);
        throw ApiServiceException(error);
      }

      AppLogger.debug(
          'Réponse reçue de l\'IA (${aiResponseText.length} caractères)');
      return aiResponseText;
    } on TimeoutException catch (e) {
      AppLogger.error('Timeout lors de la communication avec l\'API', e);
      throw ApiServiceException('La requête a expiré. Veuillez réessayer.');
    } catch (e) {
      AppLogger.error('Erreur innattendue lors de l\'appel API', e);
      throw ApiServiceException('Erreur inattendueː $e');
    }
  }

  /// Obtient l'historique des messages
  List<Content> getHistory() {
    if (!_isInitialized) {
      return [];
    }
    return _chat.history.toList();
  }

  /// Réinitialise la conversation
  void resetConversation() {
    if (_isInitialized) {
      _chat = _model.startChat(history: []);
      AppLogger.info('Conversation réinitialisée');
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _isInitialized = false;
    AppLogger.debug('ApiService disposé');
  }
}

/// Exception personnalisée pour les erreurs d'API
class ApiServiceException implements Exception {
  final String message;

  ApiServiceException(this.message);

  @override
  String toString() => message;
}
