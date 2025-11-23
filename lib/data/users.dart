class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String location;
  final String profileImageUrl;
  final DateTime memberSince;
  final bool isOnline;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String firstName;
  final String lastName;
  final String bio;
  final String passwordHash;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    required this.profileImageUrl,
    required this.memberSince,
    required this.isOnline,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.passwordHash,
  });

  String get fullName => '$firstName $lastName';

  String get formattedMemberSince {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[memberSince.month - 1]} ${memberSince.year}';
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? location,
    String? profileImageUrl,
    DateTime? memberSince,
    bool? isOnline,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? firstName,
    String? lastName,
    String? bio,
    String? passwordHash,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      memberSince: memberSince ?? this.memberSince,
      isOnline: isOnline ?? this.isOnline,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}

// Gestionnaire d'utilisateurs avec données factices
class UserManager {
  static User? _currentUser;

  // Hash SHA-256 pour les mots de passe (précalculés pour la démo)
  // sudoted -> "password123"
  static const String _hashedPassword1 =
      '0b14aeb4ac9b9eefba6bc633424cdeae0ee3aa5772a37049fec998e47463ba61';
  // marie_dev -> "marie2024"
  static const String _hashedPassword2 =
      'b88d3b6ec0e9febe0e3825b67195ad6cc27e17afd889e9e3d00a6f0e1eac10e3';

  // Données factices pour deux utilisateurs
  static final List<User> _users = [
    User(
      id: '1',
      username: 'sudoted',
      email: 'sudoted@example.com',
      phone: '+261 34 12 345 67',
      location: 'Antananarivo, Madagascar',
      profileImageUrl: '',
      memberSince: DateTime(2024, 1, 15),
      isOnline: true,
      notificationsEnabled: true,
      darkModeEnabled: false,
      firstName: 'Sudo',
      lastName: 'Ted',
      bio:
          'Développeur passionné par les nouvelles technologies et l\'intelligence artificielle.',
      passwordHash: _hashedPassword1,
    ),
    User(
      id: '2',
      username: 'marie_dev',
      email: 'marie.rakoto@gmail.com',
      phone: '+261 32 98 765 43',
      location: 'Fianarantsoa, Madagascar',
      profileImageUrl: '',
      memberSince: DateTime(2023, 8, 22),
      isOnline: false,
      notificationsEnabled: false,
      darkModeEnabled: true,
      firstName: 'Marie',
      lastName: 'Rakoto',
      bio:
          'Designer UX/UI et développeuse mobile. Aime créer des interfaces intuitives et modernes.',
      passwordHash: _hashedPassword2,
    ),
  ];

  /// Obtenir l'utilisateur actuel
  static User? get currentUser => _currentUser;

  /// Obtenir tous les utilisateurs
  static List<User> get allUsers => List.unmodifiable(_users);

  /// Obtenir un utilisateur par ID
  static User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir un utilisateur par nom d'utilisateur
  static User? getUserByUsername(String username) {
    try {
      return _users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir un utilisateur par email
  static User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Définir l'utilisateur actuel
  static void setCurrentUser(String userId) {
    _currentUser = getUserById(userId) ?? _users.first;
  }

  /// Mettre à jour un utilisateur
  static void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
    }
  }

  /// Supprimer un utilisateur
  static void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    if (_currentUser?.id == userId) {
      _currentUser = null;
    }
  }

  /// Mettre à jour l'utilisateur actuel
  static void updateCurrentUser(User updatedUser) {
    if (_currentUser != null) {
      updateUser(updatedUser);
      _currentUser = updatedUser;
    }
  }

  /// Changer le statut en ligne
  static void toggleOnlineStatus() {
    if (_currentUser != null) {
      final updatedUser =
          _currentUser!.copyWith(isOnline: !_currentUser!.isOnline);
      updateCurrentUser(updatedUser);
    }
  }

  /// Mettre à jour les paramètres de notification
  static void updateNotificationSettings(bool enabled) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(notificationsEnabled: enabled);
      updateCurrentUser(updatedUser);
    }
  }

  /// Mettre à jour les paramètres du mode sombre
  static void updateDarkModeSettings(bool enabled) {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(darkModeEnabled: enabled);
      updateCurrentUser(updatedUser);
    }
  }

  /// Initialiser avec un utilisateur par défaut
  static void initialize() {
    if (_currentUser == null) {
      setCurrentUser('1');
    }
  }

  /// Déconnexion
  static void logout() {
    _currentUser = null;
  }
}
