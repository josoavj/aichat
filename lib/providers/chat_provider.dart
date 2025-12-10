import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_test/services/firebase_service.dart';

/// Provider pour gérer les chats
class ChatProvider extends ChangeNotifier {
  final firebaseService = FirebaseService();

  Stream<QuerySnapshot>? _chatsStream;
  String? _currentChatId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Stream<QuerySnapshot>? get chatsStream => _chatsStream;
  String? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charger les chats de l'utilisateur
  void loadUserChats(String userId) {
    try {
      _chatsStream = firebaseService.firestore.getUserChats(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Créer un nouveau chat
  Future<String?> createNewChat({
    required String userId,
    required String title,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final chatId = await firebaseService.firestore.createChat(
        userId: userId,
        title: title,
      );
      _currentChatId = chatId;
      return chatId;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sélectionner un chat
  void selectChat(String chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }

  /// Mettre à jour un chat
  Future<bool> updateChat({
    required String chatId,
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.firestore.updateChat(
        chatId: chatId,
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

  /// Supprimer un chat
  Future<bool> deleteChat(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.firestore.deleteChat(chatId);
      if (_currentChatId == chatId) {
        _currentChatId = null;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer un chat spécifique
  Future<Map<String, dynamic>?> getChat(String chatId) async {
    try {
      return await firebaseService.firestore.getChat(chatId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
