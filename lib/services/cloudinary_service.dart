import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Service de gestion des uploads d'images vers Cloudinary
/// 
/// Cloudinary est utilisé pour stocker toutes les images de l'application:
/// - Photos de profil
/// - Images des posts (1-4 images)
/// - Images de groupes (optionnel)
/// 
/// Avantages:
/// - 25 GB gratuit (vs 5 GB Firebase Storage)
/// - Compression automatique (80% réduction taille)
/// - CDN mondial
/// - Pas de carte bancaire requise
/// - Transformations d'images incluses
class CloudinaryService {
  late CloudinaryPublic _cloudinary;
  
  // ✅ Credentials Cloudinary configurés
  // Cloud Name: dwhnoukrt
  // Upload Preset: dizonli_unsigned (créé manuellement)
  static const String _cloudName = 'dwhnoukrt';
  static const String _uploadPreset = 'dizonli_unsigned';

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      _cloudName,
      _uploadPreset,
      cache: false,
    );
  }

  /// Upload une photo de profil
  /// 
  /// [userId] ID de l'utilisateur
  /// [imageFile] Fichier image à uploader
  /// 
  /// Retourne l'URL publique de l'image uploadée
  /// Lance une exception en cas d'erreur
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      print('📸 Début upload photo profil pour user: $userId');
      print('📸 Fichier: ${imageFile.path}');
      print('📸 Cloud Name: $_cloudName');
      print('📸 Upload Preset: $_uploadPreset');
      
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'dizonli/profiles',
          publicId: fileName,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('✅ Upload réussi! URL: ${response.secureUrl}');
      
      // URL sécurisée (HTTPS)
      return response.secureUrl;
    } catch (e, stackTrace) {
      print('❌ Erreur upload photo profil Cloudinary: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Échec de l\'upload vers Cloudinary: $e');
    }
  }

  /// Upload plusieurs images pour un post
  /// 
  /// [userId] ID de l'utilisateur
  /// [imageFiles] Liste des fichiers images (max 4)
  /// 
  /// Retourne la liste des URLs des images uploadées
  Future<List<String>> uploadPostImages(String userId, List<File> imageFiles) async {
    final urls = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}-$i';
        
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFiles[i].path,
            folder: 'dizonli/posts',
            publicId: fileName,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        
        urls.add(response.secureUrl);
      } catch (e) {
        print('❌ Erreur upload image post $i Cloudinary: $e');
        // Continue avec les autres images même si une échoue
      }
    }
    
    return urls;
  }

  /// Upload une image de groupe
  /// 
  /// [groupId] ID du groupe
  /// [imageFile] Fichier image à uploader
  /// 
  /// Retourne l'URL publique de l'image uploadée
  /// Retourne null en cas d'erreur
  Future<String?> uploadGroupImage(String groupId, File imageFile) async {
    try {
      final fileName = '$groupId-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'dizonli/groups',
          publicId: fileName,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      print('❌ Erreur upload image groupe Cloudinary: $e');
      return null;
    }
  }

  /// Upload une image générique
  /// 
  /// [imageFile] Fichier image à uploader
  /// [folder] Dossier de destination (ex: 'profiles', 'posts', 'groups')
  /// 
  /// Retourne l'URL publique de l'image uploadée
  /// Retourne null en cas d'erreur
  Future<String?> uploadImage(File imageFile, {String folder = 'dizonli/misc'}) async {
    try {
      final fileName = 'img-${DateTime.now().millisecondsSinceEpoch}';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          publicId: fileName,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      print('❌ Erreur upload image Cloudinary: $e');
      return null;
    }
  }

  /// Supprime une image de Cloudinary
  /// 
  /// Note: Nécessite une configuration avancée (signed upload)
  /// Pour l'instant, les images restent sur Cloudinary même après suppression dans l'app
  /// 
  /// Solution future: Utiliser un backend ou Cloud Functions pour supprimer
  /// avec les credentials admin Cloudinary
  Future<void> deleteFile(String publicId) async {
    try {
      // La suppression nécessite une API key/secret (pas exposable côté client)
      // Options:
      // 1. Backend/Cloud Functions qui appelle l'API Admin Cloudinary
      // 2. Auto-modération Cloudinary (suppression auto images non utilisées > 30j)
      // 3. Nettoyage manuel périodique via dashboard Cloudinary
      
      print('ℹ️ Suppression Cloudinary: nécessite backend (API key/secret)');
      print('ℹ️ Pour l\'instant, supprimer manuellement via dashboard Cloudinary');
    } catch (e) {
      print('❌ Erreur suppression Cloudinary: $e');
    }
  }

  /// Obtient une URL transformée pour une image
  /// 
  /// Exemple: Créer un thumbnail, resize, crop, etc.
  /// 
  /// [originalUrl] URL originale de l'image
  /// [width] Largeur souhaitée
  /// [height] Hauteur souhaitée
  /// [crop] Type de crop ('fill', 'fit', 'scale', etc.)
  /// 
  /// Retourne l'URL transformée
  String getTransformedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String crop = 'fill',
  }) {
    try {
      // Exemple: https://res.cloudinary.com/demo/image/upload/v1234/sample.jpg
      // Devient: https://res.cloudinary.com/demo/image/upload/w_200,h_200,c_fill/v1234/sample.jpg
      
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments.toList();
      
      // Trouver l'index de 'upload'
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;
      
      // Construire la transformation
      final transformations = <String>[];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('c_$crop');
      transformations.add('q_auto'); // Qualité automatique
      transformations.add('f_auto'); // Format automatique (WebP si supporté)
      
      final transformation = transformations.join(',');
      
      // Insérer après 'upload'
      pathSegments.insert(uploadIndex + 1, transformation);
      
      return Uri(
        scheme: uri.scheme,
        host: uri.host,
        pathSegments: pathSegments,
      ).toString();
    } catch (e) {
      print('❌ Erreur transformation URL: $e');
      return originalUrl;
    }
  }

  /// Obtient un thumbnail d'une image (200x200)
  String getThumbnailUrl(String originalUrl) {
    return getTransformedUrl(originalUrl, width: 200, height: 200);
  }

  /// Obtient une version optimisée pour avatar (300x300)
  String getAvatarUrl(String originalUrl) {
    return getTransformedUrl(originalUrl, width: 300, height: 300, crop: 'fill');
  }

  /// Obtient une version optimisée pour post (800px largeur)
  String getPostImageUrl(String originalUrl) {
    return getTransformedUrl(originalUrl, width: 800);
  }
}
