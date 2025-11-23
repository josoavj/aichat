import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/users.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;
  User? _currentUser;
  bool _isInitialized = false;

  // Constantes pour les clés SharedPreferences
  static const String _keyCurrentUserId = 'auth_current_user_id';
  static const String _keyRememberMe = 'auth_remember_me';
  static const String _keySessionToken = 'auth_session_token';
  static const String _keyLoginAttempts = 'auth_login_attempts';
  static const String _keyLastLoginAttempt = 'auth_last_login_attempt';

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Initialiser le service d'authentification
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadCurrentUser();
    _isInitialized = true;
  }

  /// Charger l'utilisateur actuellement connecté
  Future<void> _loadCurrentUser() async {
    final userId = _prefs.getString(_keyCurrentUserId);
    if (userId != null) {
      _currentUser = UserManager.getUserById(userId);
    }
  }

  /// Connexion utilisateur
  Future<void> login(String username, String password,
      {bool rememberMe = false}) async {
    if (!_isInitialized) await initialize();

    // Vérifier les tentatives de connexion échouées (protection brute force)
    _checkLoginAttempts();

    // Valider les champs
    if (username.trim().isEmpty) {
      throw AuthException('Le nom d\'utilisateur ne peut pas être vide');
    }
    if (password.isEmpty) {
      throw AuthException('Le mot de passe ne peut pas être vide');
    }
    if (password.length < 6) {
      throw AuthException(
          'Le mot de passe doit contenir au moins 6 caractères');
    }

    // Chercher l'utilisateur
    final user = UserManager.getUserByUsername(username);
    if (user == null) {
      _recordFailedLoginAttempt();
      throw AuthException('Nom d\'utilisateur ou mot de passe incorrect');
    }

    // Vérifier le mot de passe
    if (!_verifyPassword(password, user.passwordHash)) {
      _recordFailedLoginAttempt();
      throw AuthException('Nom d\'utilisateur ou mot de passe incorrect');
    }

    // Connexion réussie
    _currentUser = user;
    final sessionToken = _generateSessionToken();

    await Future.wait([
      _prefs.setString(_keyCurrentUserId, user.id),
      _prefs.setString(_keySessionToken, sessionToken),
      _prefs.setBool(_keyRememberMe, rememberMe),
      _prefs.setString('last_login', DateTime.now().toIso8601String()),
    ]);

    // Réinitialiser les tentatives échouées
    await _prefs.remove(_keyLoginAttempts);
    await _prefs.remove(_keyLastLoginAttempt);
  }

  /// Déconnexion
  Future<void> logout() async {
    if (!_isInitialized) await initialize();

    _currentUser = null;
    await Future.wait([
      _prefs.remove(_keyCurrentUserId),
      _prefs.remove(_keySessionToken),
      _prefs.remove(_keyRememberMe),
    ]);
  }

  /// Changer le mot de passe
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (!_isInitialized) await initialize();
    if (_currentUser == null) {
      throw AuthException('Aucun utilisateur connecté');
    }

    // Vérifier l'ancien mot de passe
    if (!_verifyPassword(oldPassword, _currentUser!.passwordHash)) {
      throw AuthException('L\'ancien mot de passe est incorrect');
    }

    // Valider le nouveau mot de passe
    if (newPassword.isEmpty) {
      throw AuthException('Le mot de passe ne peut pas être vide');
    }
    if (newPassword.length < 6) {
      throw AuthException(
          'Le mot de passe doit contenir au moins 6 caractères');
    }
    if (oldPassword == newPassword) {
      throw AuthException(
          'Le nouveau mot de passe ne doit pas être identique à l\'ancien');
    }

    // Mettre à jour le mot de passe
    final updatedUser = _currentUser!.copyWith(
      passwordHash: _hashPassword(newPassword),
    );
    UserManager.updateUser(updatedUser);
    _currentUser = updatedUser;
  }

  /// Réinitialiser le mot de passe (simulation - dans un vrai projet, envoyer un email)
  Future<void> resetPassword(String email) async {
    if (!_isInitialized) await initialize();

    if (!_isValidEmail(email)) {
      throw AuthException('Email invalide');
    }

    final user = UserManager.getUserByEmail(email);
    if (user == null) {
      // Ne pas révéler si l'email existe ou non (sécurité)
      return;
    }

    // Dans un vrai projet, envoyer un email avec un lien de réinitialisation
    // Pour la démo, on génère un mot de passe temporaire
    final tempPassword = _generateTemporaryPassword();
    final updatedUser = user.copyWith(
      passwordHash: _hashPassword(tempPassword),
    );
    UserManager.updateUser(updatedUser);

    // Dans un vrai projet: envoyer tempPassword par email
    print('Mot de passe temporaire: $tempPassword');
  }

  /// Supprimer le compte
  Future<void> deleteAccount(String password) async {
    if (!_isInitialized) await initialize();
    if (_currentUser == null) {
      throw AuthException('Aucun utilisateur connecté');
    }

    // Vérifier le mot de passe
    if (!_verifyPassword(password, _currentUser!.passwordHash)) {
      throw AuthException('Le mot de passe est incorrect');
    }

    // Supprimer les données utilisateur
    UserManager.deleteUser(_currentUser!.id);
    await logout();
  }

  /// Obtenir l'utilisateur actuellement connecté
  User? get currentUser => _currentUser;

  /// Vérifier si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  /// Obtenir le token de session
  String? get sessionToken => _prefs.getString(_keySessionToken);

  /// Vérifier si "Remember Me" est activé
  bool get isRememberMeEnabled => _prefs.getBool(_keyRememberMe) ?? false;

  // === Méthodes privées ===

  /// Hacher un mot de passe avec SHA-256
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Vérifier si un mot de passe correspond à son hash
  bool _verifyPassword(String password, String passwordHash) {
    return _hashPassword(password) == passwordHash;
  }

  /// Générer un token de session
  String _generateSessionToken() {
    return sha256
        .convert(utf8.encode(
            '${_currentUser!.id}-${DateTime.now().millisecondsSinceEpoch}'))
        .toString();
  }

  /// Générer un mot de passe temporaire
  String _generateTemporaryPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random =
        List.generate(12, (index) => chars[(index * 7) % chars.length]).join();
    return random;
  }

  /// Valider un email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Vérifier les tentatives de connexion échouées (brute force protection)
  void _checkLoginAttempts() {
    final attempts = _prefs.getInt(_keyLoginAttempts) ?? 0;
    final lastAttemptTime = _prefs.getString(_keyLastLoginAttempt);

    if (attempts >= 5 && lastAttemptTime != null) {
      final lastAttempt = DateTime.parse(lastAttemptTime);
      final differenceInMinutes =
          DateTime.now().difference(lastAttempt).inMinutes;

      if (differenceInMinutes < 15) {
        throw AuthException(
          'Trop de tentatives échouées. Veuillez réessayer dans ${15 - differenceInMinutes} minutes.',
        );
      } else {
        // Réinitialiser les tentatives après 15 minutes
        _prefs.remove(_keyLoginAttempts);
      }
    }
  }

  /// Enregistrer une tentative de connexion échouée
  void _recordFailedLoginAttempt() {
    final attempts = _prefs.getInt(_keyLoginAttempts) ?? 0;
    _prefs.setInt(_keyLoginAttempts, attempts + 1);
    _prefs.setString(_keyLastLoginAttempt, DateTime.now().toIso8601String());
  }
}
