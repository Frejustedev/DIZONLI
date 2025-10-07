import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service de gestion du stockage Firebase Storage
/// Gère l'upload, la suppression et la récupération d'images
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload une image vers Firebase Storage
  /// 
  /// [file] - Le fichier image à uploader
  /// [storagePath] - Le chemin dans Firebase Storage (ex: 'users/123/profile.jpg')
  /// 
  /// Retourne l'URL de téléchargement de l'image
  Future<String> uploadImage(File file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      
      // Métadonnées du fichier
      final metadata = SettableMetadata(
        contentType: _getContentType(file.path),
        cacheControl: 'max-age=31536000', // 1 an
      );

      // Upload du fichier
      final uploadTask = ref.putFile(file, metadata);
      
      // Attendre la fin de l'upload
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Récupérer l'URL de téléchargement
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload une photo de profil pour un utilisateur
  /// 
  /// [userId] - ID de l'utilisateur
  /// [file] - Le fichier image à uploader
  /// 
  /// Retourne l'URL de téléchargement de l'image
  Future<String> uploadProfilePicture(String userId, File file) async {
    try {
      // Supprime l'ancienne photo de profil si elle existe
      await deleteProfilePicture(userId).catchError((_) {});
      
      // Génère un nouveau nom de fichier
      final extension = path.extension(file.path);
      final fileName = 'profile_${_uuid.v4()}$extension';
      final storagePath = 'users/$userId/profile/$fileName';
      
      return await uploadImage(file, storagePath);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de la photo de profil: $e');
    }
  }

  /// Upload une image de post social
  /// 
  /// [userId] - ID de l'utilisateur qui poste
  /// [postId] - ID du post
  /// [file] - Le fichier image à uploader
  /// [index] - Index de l'image si multiple (optionnel)
  /// 
  /// Retourne l'URL de téléchargement de l'image
  Future<String> uploadPostImage(
    String userId,
    String postId,
    File file, {
    int? index,
  }) async {
    try {
      final extension = path.extension(file.path);
      final indexSuffix = index != null ? '_$index' : '';
      final fileName = 'post_${postId}${indexSuffix}_${_uuid.v4()}$extension';
      final storagePath = 'posts/$userId/$postId/$fileName';
      
      return await uploadImage(file, storagePath);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image du post: $e');
    }
  }

  /// Upload une image de groupe
  /// 
  /// [groupId] - ID du groupe
  /// [file] - Le fichier image à uploader
  /// 
  /// Retourne l'URL de téléchargement de l'image
  Future<String> uploadGroupImage(String groupId, File file) async {
    try {
      // Supprime l'ancienne image du groupe si elle existe
      await deleteGroupImage(groupId).catchError((_) {});
      
      final extension = path.extension(file.path);
      final fileName = 'group_${_uuid.v4()}$extension';
      final storagePath = 'groups/$groupId/$fileName';
      
      return await uploadImage(file, storagePath);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image du groupe: $e');
    }
  }

  /// Supprime une image de Firebase Storage
  /// 
  /// [storagePath] - Le chemin complet de l'image dans Storage
  Future<void> deleteImage(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Supprime une image à partir de son URL
  /// 
  /// [imageUrl] - L'URL complète de l'image
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Supprime la photo de profil d'un utilisateur
  /// 
  /// [userId] - ID de l'utilisateur
  Future<void> deleteProfilePicture(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile');
      
      // Liste tous les fichiers dans le dossier profile
      final listResult = await ref.listAll();
      
      // Supprime tous les fichiers
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la photo de profil: $e');
    }
  }

  /// Supprime l'image d'un groupe
  /// 
  /// [groupId] - ID du groupe
  Future<void> deleteGroupImage(String groupId) async {
    try {
      final ref = _storage.ref().child('groups/$groupId');
      
      // Liste tous les fichiers dans le dossier du groupe
      final listResult = await ref.listAll();
      
      // Supprime tous les fichiers
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image du groupe: $e');
    }
  }

  /// Supprime toutes les images d'un post
  /// 
  /// [userId] - ID de l'utilisateur
  /// [postId] - ID du post
  Future<void> deletePostImages(String userId, String postId) async {
    try {
      final ref = _storage.ref().child('posts/$userId/$postId');
      
      // Liste tous les fichiers dans le dossier du post
      final listResult = await ref.listAll();
      
      // Supprime tous les fichiers
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression des images du post: $e');
    }
  }

  /// Récupère l'URL de téléchargement d'une image
  /// 
  /// [storagePath] - Le chemin de l'image dans Storage
  /// 
  /// Retourne l'URL de téléchargement
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'URL: $e');
    }
  }

  /// Vérifie si une image existe dans Storage
  /// 
  /// [storagePath] - Le chemin de l'image dans Storage
  /// 
  /// Retourne true si l'image existe, false sinon
  Future<bool> imageExists(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Détermine le type de contenu basé sur l'extension du fichier
  /// 
  /// [filePath] - Le chemin du fichier
  /// 
  /// Retourne le type MIME du fichier
  String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.bmp':
        return 'image/bmp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Upload multiple images pour un post
  /// 
  /// [userId] - ID de l'utilisateur
  /// [postId] - ID du post
  /// [files] - Liste des fichiers à uploader
  /// 
  /// Retourne une liste d'URLs des images uploadées
  Future<List<String>> uploadMultiplePostImages(
    String userId,
    String postId,
    List<File> files,
  ) async {
    try {
      final urls = <String>[];
      
      for (var i = 0; i < files.length; i++) {
        final url = await uploadPostImage(
          userId,
          postId,
          files[i],
          index: i,
        );
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload des images: $e');
    }
  }

  /// Compresse une image avant l'upload (optionnel, nécessite flutter_image_compress)
  /// Cette méthode est un placeholder pour une future implémentation
  Future<File> compressImage(File file) async {
    // TODO: Implémenter la compression avec flutter_image_compress
    return file;
  }

  /// Redimensionne une image (optionnel, nécessite image package)
  /// Cette méthode est un placeholder pour une future implémentation
  Future<File> resizeImage(File file, int maxWidth, int maxHeight) async {
    // TODO: Implémenter le redimensionnement
    return file;
  }
}
