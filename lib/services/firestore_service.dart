import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_test/config/firebase_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== UTILISATEURS =====

  /// Créer un nouveau document utilisateur
  Future<void> createUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set({
        FirebaseConstants.userEmailField: email,
        FirebaseConstants.userNameField: displayName ?? '',
        FirebaseConstants.userPhotoUrlField: photoUrl ?? '',
        FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
        FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Erreur lors de la création de l\'utilisateur: $e';
    }
  }

  /// Récupérer les données d'un utilisateur
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      return doc.data();
    } catch (e) {
      throw 'Erreur lors de la récupération de l\'utilisateur: $e';
    }
  }

  /// Mettre à jour les données d'un utilisateur
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data[FirebaseConstants.updatedAtField] = FieldValue.serverTimestamp();
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update(data);
    } catch (e) {
      throw 'Erreur lors de la mise à jour de l\'utilisateur: $e';
    }
  }

  /// Récupérer tous les utilisateurs (stream)
  Stream<QuerySnapshot> getAllUsers() {
    try {
      return _firestore
          .collection(FirebaseConstants.usersCollection)
          .snapshots();
    } catch (e) {
      throw 'Erreur lors de la récupération des utilisateurs: $e';
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw 'Erreur lors de la suppression de l\'utilisateur: $e';
    }
  }

  // ===== CHATS =====

  /// Créer un nouveau chat
  Future<String> createChat({
    required String userId,
    required String title,
  }) async {
    try {
      final docRef =
          await _firestore.collection(FirebaseConstants.chatsCollection).add({
        'userId': userId,
        'title': title,
        'messageCount': 0,
        FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
        FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'Erreur lors de la création du chat: $e';
    }
  }

  /// Récupérer les chats d'un utilisateur
  Stream<QuerySnapshot> getUserChats(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.chatsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy(FirebaseConstants.updatedAtField, descending: true)
          .snapshots();
    } catch (e) {
      throw 'Erreur lors de la récupération des chats: $e';
    }
  }

  /// Récupérer un chat spécifique
  Future<Map<String, dynamic>?> getChat(String chatId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .get();
      return doc.data();
    } catch (e) {
      throw 'Erreur lors de la récupération du chat: $e';
    }
  }

  /// Mettre à jour un chat
  Future<void> updateChat({
    required String chatId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data[FirebaseConstants.updatedAtField] = FieldValue.serverTimestamp();
      await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .update(data);
    } catch (e) {
      throw 'Erreur lors de la mise à jour du chat: $e';
    }
  }

  /// Supprimer un chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Supprimer tous les messages du chat
      final messages = await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .collection(FirebaseConstants.messagesCollection)
          .get();

      for (final doc in messages.docs) {
        await doc.reference.delete();
      }

      // Supprimer le chat
      await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .delete();
    } catch (e) {
      throw 'Erreur lors de la suppression du chat: $e';
    }
  }

  // ===== MESSAGES =====

  /// Ajouter un message à un chat
  Future<String> addMessage({
    required String chatId,
    required String userId,
    required String content,
    required String role,
  }) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .collection(FirebaseConstants.messagesCollection)
          .add({
        'userId': userId,
        'content': content,
        'role': role, // 'user' ou 'assistant'
        'tokens': 0,
        FirebaseConstants.createdAtField: FieldValue.serverTimestamp(),
      });

      // Incrémenter le compteur de messages
      await updateChat(
        chatId: chatId,
        data: {
          'messageCount': FieldValue.increment(1),
        },
      );

      return docRef.id;
    } catch (e) {
      throw 'Erreur lors de l\'ajout du message: $e';
    }
  }

  /// Récupérer les messages d'un chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .collection(FirebaseConstants.messagesCollection)
          .orderBy(FirebaseConstants.createdAtField, descending: false)
          .snapshots();
    } catch (e) {
      throw 'Erreur lors de la récupération des messages: $e';
    }
  }

  /// Mettre à jour un message
  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .collection(FirebaseConstants.messagesCollection)
          .doc(messageId)
          .update(data);
    } catch (e) {
      throw 'Erreur lors de la mise à jour du message: $e';
    }
  }

  /// Supprimer un message
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.chatsCollection)
          .doc(chatId)
          .collection(FirebaseConstants.messagesCollection)
          .doc(messageId)
          .delete();
    } catch (e) {
      throw 'Erreur lors de la suppression du message: $e';
    }
  }

  // ===== BATCH OPERATIONS =====

  /// Exécuter plusieurs opérations en une seule transaction
  Future<void> runBatchWrite(Function(WriteBatch) Function) async {
    try {
      final batch = _firestore.batch();
      Function(batch);
      await batch.commit();
    } catch (e) {
      throw 'Erreur lors de l\'exécution batch: $e';
    }
  }
}
