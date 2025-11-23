import 'package:google_generative_ai/google_generative_ai.dart';

/// Service pour gérer l'API Generative AI
class ApiService {
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isInitialized = false;

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
    } catch (e) {
      throw ApiServiceException('Erreur lors de l\'initialisation: $e');
    }
  }

  /// Vérifie si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Envoie un message et retourne la réponse
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      throw ApiServiceException(
          'Service non initialisé. Initialisez d\'abord avec initialize()');
    }

    if (message.trim().isEmpty) {
      throw ApiServiceException('Le message ne peut pas être vide');
    }

    try {
      final userMessage = Content.text(message.trim());
      final response = await _chat.sendMessage(userMessage);

      if (response.candidates.isEmpty) {
        throw ApiServiceException('Aucune réponse valide de l\'IA reçue.');
      }

      final aiResponseText = response.candidates.first.content.parts
          .whereType<TextPart>()
          .map<String>((e) => e.text)
          .join('');

      if (aiResponseText.isEmpty) {
        throw ApiServiceException('La réponse de l\'IA est vide');
      }

      return aiResponseText;
    } on GenerativeAIException catch (e) {
      throw ApiServiceException('Erreur API: ${e.message}');
    } catch (e) {
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
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _isInitialized = false;
  }
}

/// Exception personnalisée pour les erreurs d'API
class ApiServiceException implements Exception {
  final String message;

  ApiServiceException(this.message);

  @override
  String toString() => message;
}
