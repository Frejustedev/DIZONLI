import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../constants/app_colors.dart';

/// Helper pour faciliter la sélection et le recadrage d'images
class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// Affiche un dialogue de sélection de source (caméra ou galerie)
  /// 
  /// [context] - Le BuildContext pour afficher le dialogue
  /// [cropSquare] - Si true, recadre l'image en carré (pour les avatars)
  /// [cropTitle] - Titre du recadrage (optionnel)
  /// 
  /// Retourne le fichier image sélectionné et recadré, ou null si annulé
  Future<File?> pickAndCropImage(
    BuildContext context, {
    bool cropSquare = false,
    String cropTitle = 'Recadrer l\'image',
  }) async {
    // Affiche le dialogue de choix de source
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;

    // Sélectionne l'image
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85, // Qualité d'image (0-100)
      maxWidth: 1920, // Largeur max
      maxHeight: 1920, // Hauteur max
    );

    if (image == null) return null;

    // Recadre l'image
    return await _cropImage(
      image.path,
      cropSquare: cropSquare,
      title: cropTitle,
    );
  }

  /// Sélectionne une image de profil (carré)
  /// 
  /// [context] - Le BuildContext pour afficher le dialogue
  /// 
  /// Retourne le fichier image sélectionné et recadré, ou null si annulé
  Future<File?> pickProfileImage(BuildContext context) async {
    return await pickAndCropImage(
      context,
      cropSquare: true,
      cropTitle: 'Recadrer la photo de profil',
    );
  }

  /// Sélectionne une image de post (format libre)
  /// 
  /// [context] - Le BuildContext pour afficher le dialogue
  /// 
  /// Retourne le fichier image sélectionné et recadré, ou null si annulé
  Future<File?> pickPostImage(BuildContext context) async {
    return await pickAndCropImage(
      context,
      cropSquare: false,
      cropTitle: 'Recadrer l\'image',
    );
  }

  /// Sélectionne plusieurs images (sans recadrage)
  /// 
  /// [maxImages] - Nombre maximum d'images (défaut: 5)
  /// 
  /// Retourne une liste de fichiers images, ou une liste vide si annulé
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Limite le nombre d'images
      final limitedImages = images.take(maxImages).toList();

      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la sélection d\'images: $e');
      return [];
    }
  }

  /// Affiche un dialogue de choix entre caméra et galerie
  /// 
  /// [context] - Le BuildContext pour afficher le dialogue
  /// 
  /// Retourne la source choisie, ou null si annulé
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle visuel
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Titre
                const Text(
                  'Choisir une source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Option Caméra
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Prendre une photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Utiliser l\'appareil photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),

                const SizedBox(height: 8),

                // Option Galerie
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text(
                    'Choisir depuis la galerie',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Sélectionner une photo existante'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),

                const SizedBox(height: 8),

                // Bouton Annuler
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Recadre une image
  /// 
  /// [imagePath] - Chemin du fichier image
  /// [cropSquare] - Si true, recadre en carré
  /// [title] - Titre de l'écran de recadrage
  /// 
  /// Retourne le fichier image recadré, ou null si annulé
  Future<File?> _cropImage(
    String imagePath, {
    bool cropSquare = false,
    String title = 'Recadrer l\'image',
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: cropSquare,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: cropSquare,
            resetAspectRatioEnabled: !cropSquare,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du recadrage: $e');
      return File(imagePath); // Retourne l'image originale en cas d'erreur
    }
  }

  /// Affiche un dialogue de confirmation avant de supprimer une image
  /// 
  /// [context] - Le BuildContext pour afficher le dialogue
  /// 
  /// Retourne true si l'utilisateur confirme, false sinon
  static Future<bool> confirmDeleteImage(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer l\'image'),
          content: const Text(
            'Voulez-vous vraiment supprimer cette image ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
