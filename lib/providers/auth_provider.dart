import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_test/services/firebase_service.dart';

/// Provider pour gérer l'état d'authentification
class AuthProvider extends ChangeNotifier {
  final firebaseService = FirebaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Initialiser en écoutant les changements d'authentification
    firebaseService.auth.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Créer un compte
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await firebaseService.auth
          .signUpWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Créer le document utilisateur
        await firebaseService.firestore.createUser(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
        );

        // Mettre à jour le display name
        await firebaseService.auth.updateUserProfile(displayName: displayName);

        _currentUser = credential.user;
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

  /// Se connecter
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await firebaseService.auth
          .signInWithEmailAndPassword(email: email, password: password);
      _currentUser = credential.user;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Se déconnecter
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await firebaseService.auth.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.auth.resetPassword(email: email);
      _errorMessage = 'Email de réinitialisation envoyé';
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour le profil
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firebaseService.auth.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      if (_currentUser != null) {
        await firebaseService.firestore.updateUser(
          uid: _currentUser!.uid,
          data: {
            if (displayName != null) 'name': displayName,
            if (photoUrl != null) 'photoUrl': photoUrl,
          },
        );
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

  /// Supprimer le compte
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        // Supprimer les données utilisateur de Firestore
        await firebaseService.firestore.deleteUser(_currentUser!.uid);

        // Supprimer le compte Firebase
        await firebaseService.auth.deleteAccount();
        _currentUser = null;
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
