import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'firestore_service.dart';

/// Service de gestion des notifications
class NotificationService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notifications';
  final Uuid _uuid = const Uuid();

  /// Crée une notification
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? senderUserId,
    String? senderName,
    String? senderPhotoUrl,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = _uuid.v4();
      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        type: type,
        title: title,
        body: body,
        senderUserId: senderUserId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        relatedId: relatedId,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createDocument(
        _collection,
        notificationId,
        notification.toJson(),
      );

      return notificationId;
    } catch (e) {
      throw Exception('Erreur lors de la création de la notification: $e');
    }
  }

  /// Stream des notifications d'un utilisateur
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Stream des notifications non lues
  Stream<List<NotificationModel>> streamUnreadNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestoreService.updateDocument(
        _collection,
        notificationId,
        {'isRead': true},
      );
    } catch (e) {
      throw Exception('Erreur lors du marquage de la notification: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du marquage des notifications: $e');
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestoreService.deleteDocument(_collection, notificationId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }

  /// Supprime toutes les notifications d'un utilisateur
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des notifications: $e');
    }
  }

  /// Compte les notifications non lues
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // === Notifications prédéfinies ===

  /// Notification de demande d'ami
  Future<void> notifyFriendRequest(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.friendRequest,
      title: 'Nouvelle demande d\'ami',
      body: '$fromUserName vous a envoyé une demande d\'ami',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
    );
  }

  /// Notification de demande d'ami acceptée
  Future<void> notifyFriendRequestAccepted(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.friendRequestAccepted,
      title: 'Demande d\'ami acceptée',
      body: '$fromUserName a accepté votre demande d\'ami',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
    );
  }

  /// Notification de like sur un post
  Future<void> notifyPostLike(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto, String postId) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.postLike,
      title: 'Nouveau like',
      body: '$fromUserName a aimé votre post',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
      relatedId: postId,
    );
  }

  /// Notification de commentaire sur un post
  Future<void> notifyPostComment(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto, String postId, String commentText) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.postComment,
      title: 'Nouveau commentaire',
      body: '$fromUserName a commenté votre post: "$commentText"',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
      relatedId: postId,
      data: {'commentText': commentText},
    );
  }

  /// Notification d'invitation à un défi
  Future<void> notifyChallengeInvite(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto, String challengeId, String challengeTitle) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.challengeInvite,
      title: 'Invitation à un défi',
      body: '$fromUserName vous invite à rejoindre le défi "$challengeTitle"',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
      relatedId: challengeId,
      data: {'challengeTitle': challengeTitle},
    );
  }

  /// Notification de défi complété
  Future<void> notifyChallengeComplete(String userId, String challengeTitle, String challengeId) async {
    await createNotification(
      userId: userId,
      type: NotificationType.challengeComplete,
      title: 'Défi complété !',
      body: 'Félicitations ! Vous avez terminé le défi "$challengeTitle"',
      relatedId: challengeId,
      data: {'challengeTitle': challengeTitle},
    );
  }

  /// Notification de badge gagné
  Future<void> notifyBadgeEarned(String userId, String badgeTitle, String badgeId) async {
    await createNotification(
      userId: userId,
      type: NotificationType.badgeEarned,
      title: 'Nouveau badge débloqué !',
      body: 'Vous avez gagné le badge "$badgeTitle"',
      relatedId: badgeId,
      data: {'badgeTitle': badgeTitle},
    );
  }

  /// Notification d'invitation à un groupe
  Future<void> notifyGroupInvite(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto, String groupId, String groupName) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.groupInvite,
      title: 'Invitation à un groupe',
      body: '$fromUserName vous invite à rejoindre le groupe "$groupName"',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
      relatedId: groupId,
      data: {'groupName': groupName},
    );
  }

  /// Notification de membre ayant rejoint un groupe
  Future<void> notifyGroupJoined(String toUserId, String fromUserId, String fromUserName, String? fromUserPhoto, String groupId, String groupName) async {
    await createNotification(
      userId: toUserId,
      type: NotificationType.groupJoined,
      title: 'Nouveau membre',
      body: '$fromUserName a rejoint le groupe "$groupName"',
      senderUserId: fromUserId,
      senderName: fromUserName,
      senderPhotoUrl: fromUserPhoto,
      relatedId: groupId,
      data: {'groupName': groupName},
    );
  }

  /// Notification d'accomplissement générique
  Future<void> notifyAchievement(String userId, String title, String body, {Map<String, dynamic>? data}) async {
    await createNotification(
      userId: userId,
      type: NotificationType.achievement,
      title: title,
      body: body,
      data: data,
    );
  }
}

