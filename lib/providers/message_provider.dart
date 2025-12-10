import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_test/services/firebase_service.dart';

/// Provider pour gérer les messages d'un chat
class MessageProvider extends ChangeNotifier {
  final firebaseService = FirebaseService();

  Stream<QuerySnapshot>? _messagesStream;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Stream<QuerySnapshot>? get messagesStream => _messagesStream;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charger les messages d'un chat
  void loadChatMessages(String chatId) {
    try {
      _messagesStream = firebaseService.firestore.getChatMessages(chatId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Ajouter un message
  Future<String?> addMessage({
    required String chatId,
    required String userId,
    required String content,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messageId = await firebaseService.firestore.addMessage(
        chatId: chatId,
        userId: userId,
        content: content,
        role: role,
      );
      return messageId;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour un message
  Future<bool> updateMessage({
    required String chatId,
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.firestore.updateMessage(
        chatId: chatId,
        messageId: messageId,
        data: data,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer un message
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.firestore.deleteMessage(
        chatId: chatId,
        messageId: messageId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
