import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/post_model.dart';

/// Widget pour afficher un post
class PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(currentUserId);
    final canDelete = post.userId == currentUserId;

    return Card(
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
                  backgroundImage: post.userPhotoURL != null && post.userPhotoURL!.isNotEmpty
                      ? NetworkImage(post.userPhotoURL!)
                      : null,
                  child: post.userPhotoURL == null || post.userPhotoURL!.isEmpty
                      ? Text(
                          post.userName[0].toUpperCase(),
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
                        post.userName,
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
                            _formatTimestamp(post.createdAt),
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
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Image if available
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
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
                  '${post.likeCount} j\'aime',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${post.commentCount} commentaire${post.commentCount > 1 ? 's' : ''}',
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
                  onTap: () => onLike?.call(post.id, currentUserId),
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Commenter',
                  color: AppColors.textSecondary,
                  onTap: () => onComment?.call(post.id),
                ),
              ],
            ),

            // Comments preview
            if (post.comments.isNotEmpty) ...[
              const Divider(height: 24),
              ...post.comments.take(2).map((comment) => _buildCommentPreview(comment)),
              if (post.comments.length > 2)
                TextButton(
                  onPressed: () => onComment?.call(post.id),
                  child: Text('Voir les ${post.comments.length} commentaires'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeChip() {
    IconData icon;
    String label;
    Color color;

    switch (post.type) {
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
        label = 'Défi';
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
                onDelete?.call(post.id, currentUserId);
              },
            ),
          ],
        ),
      ),
    );
  }
}

