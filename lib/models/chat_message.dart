import 'package:google_generative_ai/google_generative_ai.dart';

/// Représente un message de chat avec des métadonnées
class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? error;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Crée un ChatMessage à partir d'un Content de l'API
  factory ChatMessage.fromContent(Content content) {
    final text =
        content.parts.whereType<TextPart>().map<String>((e) => e.text).join('');
    return ChatMessage(
      text: text,
      isFromUser: content.role == 'user',
    );
  }

  /// Crée un ChatMessage d'erreur
  factory ChatMessage.error(String errorMessage) {
    return ChatMessage(
      text: errorMessage,
      isFromUser: false,
      error: errorMessage,
    );
  }

  /// Convertir en Content pour l'API
  Content toContent() {
    return Content.text(text);
  }

  @override
  String toString() =>
      'ChatMessage(text: $text, isFromUser: $isFromUser, timestamp: $timestamp)';
}
