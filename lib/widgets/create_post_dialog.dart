import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_colors.dart';
import '../services/cloudinary_service.dart';
import '../services/social_service.dart';
import '../core/utils/image_picker_helper.dart';
import '../models/post_model.dart';

/// Dialogue de création de post avec upload d'images
class CreatePostDialog extends StatefulWidget {
  final String userId;
  final VoidCallback? onPostCreated;

  const CreatePostDialog({
    Key? key,
    required this.userId,
    this.onPostCreated,
  }) : super(key: key);

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final SocialService _socialService = SocialService();
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();
  final List<File> _selectedImages = [];
  bool _isPosting = false;
  static const int _maxImages = 4;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Créer un post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Champ de texte
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Quoi de neuf ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Images sélectionnées
                    if (_selectedImages.isNotEmpty) _buildImagesGrid(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                // Bouton ajouter image
                IconButton(
                  onPressed: _isPosting ? null : _addImages,
                  icon: Icon(
                    Icons.photo_library,
                    color: _isPosting
                        ? Colors.grey
                        : AppColors.primary,
                  ),
                  tooltip: 'Ajouter des images (max $_maxImages)',
                ),

                const SizedBox(width: 8),

                // Compteur d'images
                if (_selectedImages.isNotEmpty)
                  Text(
                    '${_selectedImages.length}/$_maxImages',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                const Spacer(),

                // Bouton publier
                ElevatedButton(
                  onPressed: _isPosting || _contentController.text.trim().isEmpty
                      ? null
                      : _publishPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Publier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Affiche la grille d'images sélectionnées
  Widget _buildImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRoundedRectangle(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImages[index],
                fit: BoxFit.cover,
              ),
            ),

            // Bouton supprimer
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Ajoute des images
  Future<void> _addImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous pouvez ajouter maximum $_maxImages images'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final images = await _imagePickerHelper.pickMultipleImages(
      maxImages: _maxImages - _selectedImages.length,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  /// Publie le post
  Future<void> _publishPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      // Génère l'ID du post
      final postId = const Uuid().v4();

      // Upload les images vers Cloudinary si présentes
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _cloudinaryService.uploadPostImages(
          widget.userId,
          _selectedImages,
        );
      }

      // Crée le post via le service
      await _socialService.createPost(
        userId: widget.userId,
        userName: '', // TODO: Récupérer le nom depuis UserProvider
        userPhotoURL: null, // TODO: Récupérer depuis UserProvider
        type: PostType.custom,
        content: content,
        imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
        visibility: PostVisibility.public,
      );

      // Callback
      widget.onPostCreated?.call();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Post publié avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isPosting = false);
      
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
}

/// Widget pour arrondir les coins d'une image
class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRoundedRectangle({
    Key? key,
    required this.child,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
