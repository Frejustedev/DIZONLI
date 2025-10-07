import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final int age;
  final String gender;
  final String location;
  final int dailyGoal;
  final DateTime createdAt;
  final String userLevel; // Bronze, Silver, Gold, Champion
  final List<String> groupIds;
  final int totalSteps;
  final int totalDistance; // in meters
  final int totalCalories;

  // Convenience getters for compatibility
  String get uid => id;
  List<String> get friends => const [];
  List<String> get groups => groupIds;
  List<String> get badges => const [];

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.age,
    required this.gender,
    required this.location,
    this.dailyGoal = 10000,
    required this.createdAt,
    this.userLevel = 'Bronze',
    this.groupIds = const [],
    this.totalSteps = 0,
    this.totalDistance = 0,
    this.totalCalories = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper pour convertir Timestamp ou String en DateTime
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      age: (json['age'] ?? 0).toInt(),
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      dailyGoal: (json['dailyGoal'] ?? 10000).toInt(),
      createdAt: _parseDate(json['createdAt']),
      userLevel: json['userLevel'] ?? 'Bronze',
      groupIds: List<String>.from(json['groupIds'] ?? []),
      totalSteps: (json['totalSteps'] ?? 0).toInt(),
      totalDistance: (json['totalDistance'] ?? 0).toInt(),
      totalCalories: (json['totalCalories'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'age': age,
      'gender': gender,
      'location': location,
      'dailyGoal': dailyGoal,
      'createdAt': createdAt.toIso8601String(),
      'userLevel': userLevel,
      'groupIds': groupIds,
      'totalSteps': totalSteps,
      'totalDistance': totalDistance,
      'totalCalories': totalCalories,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    int? age,
    String? gender,
    String? location,
    int? dailyGoal,
    DateTime? createdAt,
    String? userLevel,
    List<String>? groupIds,
    int? totalSteps,
    int? totalDistance,
    int? totalCalories,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      createdAt: createdAt ?? this.createdAt,
      userLevel: userLevel ?? this.userLevel,
      groupIds: groupIds ?? this.groupIds,
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistance: totalDistance ?? this.totalDistance,
      totalCalories: totalCalories ?? this.totalCalories,
    );
  }
}

