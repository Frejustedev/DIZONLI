import 'package:cloud_firestore/cloud_firestore.dart';

/// Types de défis disponibles
enum ChallengeType {
  steps,        // Défis basés sur le nombre de pas
  distance,     // Défis basés sur la distance
  duration,     // Défis basés sur la durée
  streak,       // Défis basés sur la constance (jours consécutifs)
}

/// Portée du défi
enum ChallengeScope {
  personal,     // Défi personnel
  group,        // Défi de groupe
  friends,      // Défi entre amis
  global,       // Défi global (tous les utilisateurs)
}

/// Statut du défi
enum ChallengeStatus {
  upcoming,     // À venir
  active,       // En cours
  completed,    // Terminé
  failed,       // Échoué
}

/// Modèle de défi
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeScope scope;
  final String? creatorId;        // ID du créateur (null pour défis système)
  final String? groupId;          // ID du groupe (pour défis de groupe)
  final List<String> participantIds;  // IDs des participants
  final int targetValue;          // Valeur cible (ex: 10000 pas)
  final DateTime startDate;
  final DateTime endDate;
  final int rewardPoints;         // Points de récompense
  final String? rewardBadgeId;    // Badge de récompense
  final Map<String, int> progress; // Progression de chaque participant {userId: value}
  final DateTime createdAt;
  final bool isPublic;            // Visible par tous?

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.scope,
    this.creatorId,
    this.groupId,
    required this.participantIds,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    this.rewardPoints = 0,
    this.rewardBadgeId,
    required this.progress,
    required this.createdAt,
    this.isPublic = false,
  });

  /// Obtient le statut actuel du défi
  ChallengeStatus get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return ChallengeStatus.upcoming;
    } else if (now.isAfter(endDate)) {
      return ChallengeStatus.completed;
    } else {
      return ChallengeStatus.active;
    }
  }

  /// Calcule le pourcentage de progression pour un utilisateur
  double getProgressPercentage(String userId) {
    final userProgress = progress[userId] ?? 0;
    if (targetValue == 0) return 0;
    return (userProgress / targetValue * 100).clamp(0, 100);
  }

  /// Vérifie si un utilisateur a complété le défi
  bool isCompletedBy(String userId) {
    final userProgress = progress[userId] ?? 0;
    return userProgress >= targetValue;
  }

  /// Obtient le nombre de jours restants
  int get daysRemaining {
    if (status != ChallengeStatus.active) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Obtient le nombre de participants ayant complété le défi
  int get completedCount {
    return participantIds.where((id) => isCompletedBy(id)).length;
  }

  /// Obtient le taux de complétion global
  double get completionRate {
    if (participantIds.isEmpty) return 0;
    return completedCount / participantIds.length * 100;
  }

  /// Convertit en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'scope': scope.toString().split('.').last,
      'creatorId': creatorId,
      'groupId': groupId,
      'participantIds': participantIds,
      'targetValue': targetValue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'rewardPoints': rewardPoints,
      'rewardBadgeId': rewardBadgeId,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
    };
  }

  /// Créé depuis Map Firestore
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir Timestamp ou String en DateTime
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    // Helper pour convertir Map<String, dynamic> en Map<String, int>
    Map<String, int> _parseProgress(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return value.map((key, val) => MapEntry(
          key.toString(),
          (val is int) ? val : (val as num).toInt(),
        ));
      }
      return {};
    }

    return ChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == 'ChallengeType.${json['type']}',
        orElse: () => ChallengeType.steps,
      ),
      scope: ChallengeScope.values.firstWhere(
        (e) => e.toString() == 'ChallengeScope.${json['scope']}',
        orElse: () => ChallengeScope.personal,
      ),
      creatorId: json['creatorId'],
      groupId: json['groupId'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      targetValue: (json['targetValue'] ?? 0).toInt(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      rewardPoints: (json['rewardPoints'] ?? 0).toInt(),
      rewardBadgeId: json['rewardBadgeId'],
      progress: _parseProgress(json['progress']),
      createdAt: _parseDate(json['createdAt']),
      isPublic: json['isPublic'] ?? false,
    );
  }

  /// Copie avec modifications
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeScope? scope,
    String? creatorId,
    String? groupId,
    List<String>? participantIds,
    int? targetValue,
    DateTime? startDate,
    DateTime? endDate,
    int? rewardPoints,
    String? rewardBadgeId,
    Map<String, int>? progress,
    DateTime? createdAt,
    bool? isPublic,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      creatorId: creatorId ?? this.creatorId,
      groupId: groupId ?? this.groupId,
      participantIds: participantIds ?? this.participantIds,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardBadgeId: rewardBadgeId ?? this.rewardBadgeId,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
