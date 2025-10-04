import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        final notificationProvider = context.read<NotificationProvider>();
        notificationProvider.loadNotifications(userProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'delete_all') {
                _deleteAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 8),
                    Text('Tout marquer comme lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Supprimer tout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;

          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              notificationProvider.loadNotifications(currentUser.id);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification, currentUser.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification, String currentUserId) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final notificationProvider = context.read<NotificationProvider>();
        notificationProvider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification supprimée')),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 1 : 3,
        color: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification, currentUserId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar ou icône
                _buildNotificationAvatar(notification),
                const SizedBox(width: 16),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationAvatar(NotificationModel notification) {
    if (notification.senderPhotoUrl != null && notification.senderPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: NetworkImage(notification.senderPhotoUrl!),
      );
    } else if (notification.senderName != null && notification.senderName!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          notification.senderName![0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    } else {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getNotificationColor(notification.type).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            notification.getIcon(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas encore de notifications',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, String currentUserId) {
    final notificationProvider = context.read<NotificationProvider>();

    // Marquer comme lu
    if (!notification.isRead) {
      notificationProvider.markAsRead(notification.id);
    }

    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.friendRequest:
        // Naviguer vers l'écran des amis (demandes)
        // Navigator.pushNamed(context, '/friends');
        break;
      case NotificationType.postLike:
      case NotificationType.postComment:
        // Naviguer vers le post
        // Navigator.pushNamed(context, '/post', arguments: notification.relatedId);
        break;
      case NotificationType.challengeInvite:
        // Naviguer vers le défi
        // Navigator.pushNamed(context, '/challenge', arguments: notification.relatedId);
        break;
      case NotificationType.groupInvite:
        // Naviguer vers le groupe
        // Navigator.pushNamed(context, '/group', arguments: notification.relatedId);
        break;
      default:
        // Pas de navigation spécifique
        break;
    }
  }

  void _markAllAsRead() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.currentUser == null) return;

    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.markAllAsRead(userProvider.currentUser!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications sont marquées comme lues'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les notifications'),
        content: const Text('Êtes-vous sûr de vouloir supprimer toutes vos notifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser == null) return;

      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.deleteAllNotifications(userProvider.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toutes les notifications ont été supprimées')),
        );
      }
    }
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

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequest:
      case NotificationType.friendRequestAccepted:
        return AppColors.primary;
      case NotificationType.postLike:
        return AppColors.error;
      case NotificationType.postComment:
        return AppColors.secondary;
      case NotificationType.challengeInvite:
      case NotificationType.challengeComplete:
        return AppColors.accent;
      case NotificationType.badgeEarned:
        return AppColors.gold;
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
        return AppColors.primary;
      case NotificationType.achievement:
        return AppColors.success;
    }
  }
}

