import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupType {
  friends,
  community,
  institution,
}

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final GroupType type;
  final String adminId;
  final List<String> memberIds;
  final int totalSteps;
  final DateTime createdAt;
  final String? inviteCode;
  final bool isPrivate;

  // Convenience getters for compatibility
  List<String> get members => memberIds;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.type,
    required this.adminId,
    required this.memberIds,
    this.totalSteps = 0,
    required this.createdAt,
    this.inviteCode,
    this.isPrivate = false,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir Timestamp ou String en DateTime
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      type: GroupType.values.firstWhere(
        (e) => e.toString() == 'GroupType.${json['type']}',
        orElse: () => GroupType.friends,
      ),
      adminId: json['adminId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      totalSteps: (json['totalSteps'] ?? 0).toInt(),
      createdAt: _parseDate(json['createdAt']),
      inviteCode: json['inviteCode'],
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'type': type.toString().split('.').last,
      'adminId': adminId,
      'memberIds': memberIds,
      'totalSteps': totalSteps,
      'createdAt': createdAt.toIso8601String(),
      'inviteCode': inviteCode,
      'isPrivate': isPrivate,
    };
  }
}

