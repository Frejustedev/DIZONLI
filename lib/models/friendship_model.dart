import 'package:cloud_firestore/cloud_firestore.dart';

/// Statut d'une amitié
enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}

/// Modèle d'amitié entre deux utilisateurs
class FriendshipModel {
  final String id;
  final String userId1;
  final String userId2;
  final FriendshipStatus status;
  final String requesterId;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  FriendshipModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.status,
    required this.requesterId,
    required this.createdAt,
    this.acceptedAt,
  });

  factory FriendshipModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FriendshipModel(
      id: documentId,
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
      status: _parseStatus(map['status']),
      requesterId: map['requesterId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      acceptedAt: map['acceptedAt'] != null
          ? (map['acceptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'status': status.toString().split('.').last,
      'requesterId': requesterId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  static FriendshipStatus _parseStatus(dynamic status) {
    if (status == null) return FriendshipStatus.pending;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.pending;
    }
  }

  /// Vérifie si l'utilisateur est l'expéditeur de la demande
  bool isRequester(String userId) => requesterId == userId;

  /// Obtient l'ID de l'autre utilisateur dans l'amitié
  String getOtherUserId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }

  /// Génère l'ID de document pour une amitié (IDs triés alphabétiquement)
  static String generateId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}

