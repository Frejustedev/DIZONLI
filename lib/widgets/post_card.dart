import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;
import '../core/constants/app_colors.dart';
import '../models/post_model.dart';

/// Widget pour afficher un post
class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentUserId;
  final Function(String postId, String userId)? onLike;
  final Function(String postId)? onComment;
  final Function(String postId, String userId)? onDelete;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserId,
    this.onLike,
    this.onComment,
    this.onDelete,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final GlobalKey _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLikedBy(widget.currentUserId);
    final canDelete = widget.post.userId == widget.currentUserId;

    return RepaintBoundary(
      key: _shareKey,
      child: Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Time
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: widget.post.userPhotoURL != null && widget.post.userPhotoURL!.isNotEmpty
                      ? NetworkImage(widget.post.userPhotoURL!)
                      : null,
                  child: widget.post.userPhotoURL == null || widget.post.userPhotoURL!.isEmpty
                      ? Text(
                          widget.post.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTimestamp(widget.post.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPostTypeChip(),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPostMenu(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Image if available
            if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Likes and Comments count
            Row(
              children: [
                Text(
                  '${widget.post.likeCount} j\'aime',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${widget.post.commentCount} commentaire${widget.post.commentCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'J\'aime',
                  color: isLiked ? AppColors.error : AppColors.textSecondary,
                  onTap: () => widget.onLike?.call(widget.post.id, widget.currentUserId),
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Commenter',
                  color: AppColors.textSecondary,
                  onTap: () => widget.onComment?.call(widget.post.id),
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Partager',
                  color: AppColors.textSecondary,
                  onTap: _sharePost,
                ),
              ],
            ),

            // Comments preview
            if (widget.post.comments.isNotEmpty) ...[
              const Divider(height: 24),
              ...widget.post.comments.take(2).map((comment) => _buildCommentPreview(comment)),
              if (widget.post.comments.length > 2)
                TextButton(
                  onPressed: () => widget.onComment?.call(widget.post.id),
                  child: Text('Voir les ${widget.post.comments.length} commentaires'),
                ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  // Méthode pour partager le post en image avec branding DIZONLI
  Future<void> _sharePost() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Créer une image personnalisée avec le logo et le slogan
      final image = await _createShareImage();
      
      if (!mounted) return;
      Navigator.pop(context); // Fermer l'indicateur de chargement

      if (kIsWeb) {
        // Sur le web, télécharger l'image directement
        _downloadImageWeb(image);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image téléchargée ! Vous pouvez maintenant la partager sur vos réseaux sociaux 🎉'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // Sur mobile, utiliser le partage natif
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/dizonli_post_${widget.post.id}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🏃 Découvrez mon activité sur DIZONLI\nMarchons ensemble vers une meilleure santé ! 💪\n\n#DIZONLI #MarcheTonChemin',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Fermer le dialog si erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Télécharger l'image sur le web
  void _downloadImageWeb(Uint8List imageBytes) {
    final blob = html.Blob([imageBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'DIZONLI_post_${widget.post.id}.png')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Créer une image personnalisée pour le partage
  Future<Uint8List> _createShareImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1080, 1920); // Format vertical pour les réseaux sociaux

    // Fond avec gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withOpacity(0.1),
        Colors.white,
        AppColors.primary.withOpacity(0.05),
      ],
    );
    final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // En-tête avec logo et slogan
    _drawHeader(canvas, size);

    // Contenu du post
    await _drawPostContent(canvas, size);

    // Pied de page avec marque
    _drawFooter(canvas, size);

    // Convertir en image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _drawHeader(Canvas canvas, Size size) {
    const headerHeight = 200.0;
    
    // Fond de l'en-tête
    final headerPaint = Paint()..color = AppColors.primary;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, headerHeight),
      headerPaint,
    );

    // Logo (simulé avec un cercle et icône)
    final logoPaint = Paint()..color = Colors.white;
    const logoRadius = 50.0;
    canvas.drawCircle(
      Offset(size.width / 2, 80),
      logoRadius,
      logoPaint,
    );

    // Icône dans le cercle
    final iconPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(Offset(size.width / 2, 80), logoRadius * 0.6, iconPaint);

    // Texte DIZONLI
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DIZONLI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, 145));

    // Slogan
    final sloganPainter = TextPainter(
      text: const TextSpan(
        text: 'Marchons ensemble vers une meilleure santé',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    sloganPainter.layout(maxWidth: size.width - 100);
    sloganPainter.paint(canvas, Offset((size.width - sloganPainter.width) / 2, 145 + textPainter.height + 5));
  }

  Future<void> _drawPostContent(Canvas canvas, Size size) async {
    const startY = 240.0;
    const padding = 50.0;

    // Carte du post
    final cardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardShadow = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(padding - 5, startY - 5, size.width - 2 * padding + 10, 800),
      const Radius.circular(20),
    );
    canvas.drawRRect(cardRect, cardShadow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(padding, startY, size.width - 2 * padding, 800),
        const Radius.circular(20),
      ),
      cardPaint,
    );

    double currentY = startY + 40;

    // Avatar et nom
    final avatarPaint = Paint()..color = AppColors.primaryLight;
    canvas.drawCircle(Offset(padding + 40, currentY), 30, avatarPaint);

    // Initiale
    final initialPainter = TextPainter(
      text: TextSpan(
        text: widget.post.userName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    initialPainter.layout();
    initialPainter.paint(
      canvas,
      Offset(padding + 40 - initialPainter.width / 2, currentY - initialPainter.height / 2),
    );

    // Nom d'utilisateur
    final namePainter = TextPainter(
      text: TextSpan(
        text: widget.post.userName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(padding + 90, currentY - 15));

    // Date
    final datePainter = TextPainter(
      text: TextSpan(
        text: _formatTimestamp(widget.post.createdAt),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 20,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    datePainter.layout();
    datePainter.paint(canvas, Offset(padding + 90, currentY + 15));

    currentY += 80;

    // Contenu du post
    final contentPainter = TextPainter(
      text: TextSpan(
        text: widget.post.content,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 26,
          height: 1.5,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    contentPainter.layout(maxWidth: size.width - 2 * padding - 40);
    contentPainter.paint(canvas, Offset(padding + 20, currentY));

    currentY += contentPainter.height + 60;

    // Stats (j'aime et commentaires)
    final statsPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '❤️ ${widget.post.likeCount}',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '     '),
          TextSpan(
            text: '💬 ${widget.post.commentCount}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: ui.TextDirection.ltr,
    );
    statsPainter.layout();
    statsPainter.paint(canvas, Offset(padding + 20, currentY));
  }

  void _drawFooter(Canvas canvas, Size size) {
    const footerY = 1700.0;

    // Ligne de séparation
    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(100, footerY),
      Offset(size.width - 100, footerY),
      linePaint,
    );

    // Texte du pied de page
    final footerPainter = TextPainter(
      text: const TextSpan(
        text: '🏃 Rejoignez-nous sur DIZONLI 💪',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    footerPainter.layout();
    footerPainter.paint(
      canvas,
      Offset((size.width - footerPainter.width) / 2, footerY + 30),
    );

    // Hashtag
    final hashtagPainter = TextPainter(
      text: const TextSpan(
        text: '#MarcheTonChemin',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 24,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    hashtagPainter.layout();
    hashtagPainter.paint(
      canvas,
      Offset((size.width - hashtagPainter.width) / 2, footerY + 80),
    );
  }

  Widget _buildPostTypeChip() {
    IconData icon;
    String label;
    Color color;

    switch (widget.post.type) {
      case PostType.achievement:
        icon = Icons.emoji_events;
        label = 'Exploit';
        color = AppColors.accent;
        break;
      case PostType.badge:
        icon = Icons.military_tech;
        label = 'Badge';
        color = AppColors.gold;
        break;
      case PostType.challenge:
        icon = Icons.flag;
        label = 'Podothon';
        color = AppColors.secondary;
        break;
      case PostType.custom:
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreview(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.userName}: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              comment.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call(widget.post.id, widget.currentUserId);
              },
            ),
          ],
        ),
      ),
    );
  }
}

