import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploader une image utilisateur
  Future<String> uploadUserProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Erreur lors de l\'upload de l\'image: $e';
    }
  }

  /// Uploader une image pour un chat
  Future<String> uploadChatImage({
    required String chatId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('chats/$chatId/images/$fileName');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Erreur lors de l\'upload de l\'image: $e';
    }
  }

  /// Uploader un fichier quelconque
  Future<String> uploadFile({
    required String path,
    required File file,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: contentType,
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Erreur lors de l\'upload du fichier: $e';
    }
  }

  /// Obtenir l'URL de téléchargement d'un fichier
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw 'Erreur lors de la récupération de l\'URL: $e';
    }
  }

  /// Supprimer un fichier
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      throw 'Erreur lors de la suppression du fichier: $e';
    }
  }

  /// Supprimer tous les fichiers d'un dossier
  Future<void> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final items = await ref.listAll();

      for (final item in items.items) {
        await item.delete();
      }

      for (final folder in items.prefixes) {
        await deleteFolder(folder.fullPath);
      }
    } catch (e) {
      throw 'Erreur lors de la suppression du dossier: $e';
    }
  }

  /// Obtenir la taille d'un fichier
  Future<int> getFileSize(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      throw 'Erreur lors de la récupération de la taille: $e';
    }
  }

  /// Obtenir les métadonnées d'un fichier
  Future<FullMetadata?> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } catch (e) {
      throw 'Erreur lors de la récupération des métadonnées: $e';
    }
  }

  /// Lister tous les fichiers d'un dossier
  Future<ListResult> listFiles(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      return await ref.listAll();
    } catch (e) {
      throw 'Erreur lors de la listage des fichiers: $e';
    }
  }

  /// Monitor la progression d'un upload
  UploadTask uploadFileWithProgress({
    required String path,
    required File file,
    required String contentType,
  }) {
    try {
      final ref = _storage.ref().child(path);
      return ref.putFile(
        file,
        SettableMetadata(
          contentType: contentType,
        ),
      );
    } catch (e) {
      throw 'Erreur lors du setup du monitoring: $e';
    }
  }
}
