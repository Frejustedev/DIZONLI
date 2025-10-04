import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de notification
enum NotificationType {
  friendRequest,        // Demande d'ami
  friendRequestAccepted, // Demande d'ami acceptée
  postLike,             // Like sur un post
  postComment,          // Commentaire sur un post
  challengeInvite,      // Invitation à un défi
  challengeComplete,    // Défi complété
  badgeEarned,          // Badge gagné
  groupInvite,          // Invitation à un groupe
  groupJoined,          // Quelqu'un a rejoint votre groupe
  achievement,          // Accomplissement général
}

/// Modèle de notification
class NotificationModel {
  final String id;
  final String userId;           // Destinataire de la notification
  final NotificationType type;
  final String title;
  final String body;
  final String? senderUserId;    // Expéditeur (si applicable)
  final String? senderName;
  final String? senderPhotoUrl;
  final String? relatedId;       // ID du post, défi, groupe, etc.
  final Map<String, dynamic>? data; // Données supplémentaires
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.senderUserId,
    this.senderName,
    this.senderPhotoUrl,
    this.relatedId,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.achievement,
      ),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      senderUserId: json['senderUserId'],
      senderName: json['senderName'],
      senderPhotoUrl: json['senderPhotoUrl'],
      relatedId: json['relatedId'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'senderUserId': senderUserId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'relatedId': relatedId,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? senderUserId,
    String? senderName,
    String? senderPhotoUrl,
    String? relatedId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Retourne l'icône correspondant au type de notification
  String getIcon() {
    switch (type) {
      case NotificationType.friendRequest:
      case NotificationType.friendRequestAccepted:
        return '👥';
      case NotificationType.postLike:
        return '❤️';
      case NotificationType.postComment:
        return '💬';
      case NotificationType.challengeInvite:
      case NotificationType.challengeComplete:
        return '🏆';
      case NotificationType.badgeEarned:
        return '🏅';
      case NotificationType.groupInvite:
      case NotificationType.groupJoined:
        return '👫';
      case NotificationType.achievement:
        return '🎉';
    }
  }
}

