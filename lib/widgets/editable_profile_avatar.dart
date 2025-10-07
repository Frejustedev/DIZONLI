import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/cloudinary_service.dart';
import '../services/user_service.dart';
import '../core/utils/image_picker_helper.dart';

/// Widget d'avatar de profil éditable
/// Permet à l'utilisateur de changer sa photo de profil
class EditableProfileAvatar extends StatefulWidget {
  final String userId;
  final String? photoUrl;
  final double radius;
  final VoidCallback? onPhotoUpdated;

  const EditableProfileAvatar({
    Key? key,
    required this.userId,
    this.photoUrl,
    this.radius = 50,
    this.onPhotoUpdated,
  }) : super(key: key);

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final UserService _userService = UserService();
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  bool _isUploading = false;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.photoUrl;
  }

  @override
  void didUpdateWidget(EditableProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      setState(() {
        _currentPhotoUrl = widget.photoUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.white,
          child: _isUploading
              ? const CircularProgressIndicator()
              : _currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _currentPhotoUrl!,
                        width: widget.radius * 2,
                        height: widget.radius * 2,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: widget.radius,
                            color: AppColors.primary,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: widget.radius,
                      color: AppColors.primary,
                    ),
        ),

        // Bouton d'édition
        if (!_isUploading)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _showOptionsDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

        // Indicateur de chargement
        if (_isUploading)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Affiche le dialogue d'options (changer/supprimer)
  void _showOptionsDialog() {
    showModalBottomSheet(
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
                  'Photo de profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Option Changer
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Changer la photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _changePhoto();
                  },
                ),

                const SizedBox(height: 8),

                // Option Supprimer (si une photo existe)
                if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Supprimer la photo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhoto();
                    },
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

  /// Change la photo de profil
  Future<void> _changePhoto() async {
    try {
      // Sélectionne et recadre l'image
      final File? imageFile = await _imagePickerHelper.pickProfileImage(context);
      
      if (imageFile == null) return;

      setState(() => _isUploading = true);

      // Upload l'image vers Cloudinary
      final photoUrl = await _cloudinaryService.uploadProfilePicture(
        widget.userId,
        imageFile,
      );

      // Met à jour l'utilisateur dans Firestore
      await _userService.updateUser(widget.userId, {'photoUrl': photoUrl});

      setState(() {
        _currentPhotoUrl = photoUrl;
        _isUploading = false;
      });

      // Callback
      widget.onPhotoUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo de profil mise à jour!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Supprime la photo de profil
  Future<void> _deletePhoto() async {
    // Confirme la suppression
    final confirm = await _showDeleteConfirmation();
    if (!confirm) return;

    try {
      setState(() => _isUploading = true);

      // Note: Cloudinary ne supporte pas la suppression côté client
      // L'image reste sur Cloudinary mais n'est plus référencée dans Firestore
      // Option future: Backend ou nettoyage manuel périodique

      // Met à jour l'utilisateur dans Firestore
      await _userService.updateUser(widget.userId, {'photoUrl': null});

      setState(() {
        _currentPhotoUrl = null;
        _isUploading = false;
      });

      // Callback
      widget.onPhotoUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Photo de profil supprimée'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Affiche une confirmation de suppression
  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la photo'),
          content: const Text(
            'Voulez-vous vraiment supprimer votre photo de profil ?',
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
