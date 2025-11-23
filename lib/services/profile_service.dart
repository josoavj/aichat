import 'package:shared_preferences/shared_preferences.dart';
import '../data/users.dart';

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);

  @override
  String toString() => message;
}

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static const String _keyProfileUpdates = 'profile_updates';

  factory ProfileService() {
    return _instance;
  }

  ProfileService._internal();

  /// Initialiser le service de profil
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String location,
    required String bio,
  }) async {
    if (!_isInitialized) await initialize();

    // Valider les données
    _validateFirstName(firstName);
    _validateLastName(lastName);
    _validateEmail(email);
    _validatePhone(phone);
    _validateBio(bio);

    final user = UserManager.currentUser;
    if (user == null) {
      throw ProfileException('Aucun utilisateur connecté');
    }

    // Vérifier que l'email n'est pas déjà utilisé
    if (email != user.email) {
      final existingUser = UserManager.getUserByEmail(email);
      if (existingUser != null && existingUser.id != user.id) {
        throw ProfileException('Cet email est déjà utilisé');
      }
    }

    final updatedUser = user.copyWith(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      location: location.trim(),
      bio: bio.trim(),
    );

    UserManager.updateUser(updatedUser);

    // Sauvegarder la date de dernière mise à jour
    await _prefs.setString(
      _keyProfileUpdates,
      DateTime.now().toIso8601String(),
    );
  }

  /// Mettre à jour la photo de profil (stockage local uniquement)
  Future<void> updateProfileImage(String imagePath) async {
    if (!_isInitialized) await initialize();

    if (imagePath.isEmpty) {
      throw ProfileException('Le chemin de l\'image est vide');
    }

    final user = UserManager.currentUser;
    if (user == null) {
      throw ProfileException('Aucun utilisateur connecté');
    }

    final updatedUser = user.copyWith(profileImageUrl: imagePath);
    UserManager.updateUser(updatedUser);
  }

  /// Obtenir les informations du profil actuel
  Map<String, String> getCurrentProfileInfo() {
    final user = UserManager.currentUser;
    if (user == null) {
      throw ProfileException('Aucun utilisateur connecté');
    }

    return {
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
      'location': user.location,
      'bio': user.bio,
    };
  }

  // === Méthodes privées de validation ===

  void _validateFirstName(String value) {
    if (value.trim().isEmpty) {
      throw ProfileException('Le prénom ne peut pas être vide');
    }
    if (value.length < 2) {
      throw ProfileException('Le prénom doit contenir au moins 2 caractères');
    }
    if (value.length > 50) {
      throw ProfileException('Le prénom ne doit pas dépasser 50 caractères');
    }
  }

  void _validateLastName(String value) {
    if (value.trim().isEmpty) {
      throw ProfileException('Le nom ne peut pas être vide');
    }
    if (value.length < 2) {
      throw ProfileException('Le nom doit contenir au moins 2 caractères');
    }
    if (value.length > 50) {
      throw ProfileException('Le nom ne doit pas dépasser 50 caractères');
    }
  }

  void _validateEmail(String value) {
    if (value.trim().isEmpty) {
      throw ProfileException('L\'email ne peut pas être vide');
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      throw ProfileException('Email invalide');
    }
  }

  void _validatePhone(String value) {
    if (value.trim().isEmpty) {
      throw ProfileException('Le téléphone ne peut pas être vide');
    }
    if (value.length < 10) {
      throw ProfileException('Le téléphone doit contenir au moins 10 chiffres');
    }
    if (value.length > 20) {
      throw ProfileException('Le téléphone ne doit pas dépasser 20 caractères');
    }
  }

  void _validateBio(String value) {
    if (value.length > 500) {
      throw ProfileException('La bio ne doit pas dépasser 500 caractères');
    }
  }
}
