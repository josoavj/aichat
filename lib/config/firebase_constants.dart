/// Constantes pour la configuration Firebase
class FirebaseConstants {
  // IDs de projet
  static const String projectId = 'ai-assistant-1d89a';
  static const String projectNumber = '189186346211';
  static const String storageBucket = 'ai-assistant-1d89a.firebasestorage.app';

  // Collections Firestore (à adapter selon vos besoins)
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Document fields
  static const String userNameField = 'name';
  static const String userEmailField = 'email';
  static const String userPhotoUrlField = 'photoUrl';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
}
