import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? pseudo; // Pseudonyme/username
  final String? photoUrl;
  final int age;
  final String gender;
  final String location;
  final int dailyGoal;
  final DateTime createdAt;
  final String userLevel; // Bronze, Silver, Gold, Champion
  final List<String> groupIds;
  final List<String> badges; // IDs des badges débloqués
  final int totalSteps;
  final int totalDistance; // in meters
  final int totalCalories;
  final double? height; // height in cm
  final double? weight; // weight in kg

  // Convenience getters for compatibility
  String get uid => id;
  List<String> get friends => const [];
  List<String> get groups => groupIds;
  
  // Calculer l'IMC
  double? get bmi {
    if (height == null || weight == null || height! <= 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.pseudo,
    this.photoUrl,
    required this.age,
    required this.gender,
    required this.location,
    this.dailyGoal = 10000,
    required this.createdAt,
    this.userLevel = 'Bronze',
    this.groupIds = const [],
    this.badges = const [],
    this.totalSteps = 0,
    this.totalDistance = 0,
    this.totalCalories = 0,
    this.height,
    this.weight,
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
      pseudo: json['pseudo'],
      photoUrl: json['photoUrl'],
      age: (json['age'] ?? 0).toInt(),
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      dailyGoal: (json['dailyGoal'] ?? 10000).toInt(),
      createdAt: _parseDate(json['createdAt']),
      userLevel: json['userLevel'] ?? 'Bronze',
      groupIds: List<String>.from(json['groupIds'] ?? []),
      badges: List<String>.from(json['badges'] ?? []),
      totalSteps: (json['totalSteps'] ?? 0).toInt(),
      totalDistance: (json['totalDistance'] ?? 0).toInt(),
      totalCalories: (json['totalCalories'] ?? 0).toInt(),
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'pseudo': pseudo,
      'photoUrl': photoUrl,
      'age': age,
      'gender': gender,
      'location': location,
      'dailyGoal': dailyGoal,
      'createdAt': createdAt.toIso8601String(),
      'userLevel': userLevel,
      'groupIds': groupIds,
      'badges': badges,
      'totalSteps': totalSteps,
      'totalDistance': totalDistance,
      'totalCalories': totalCalories,
      'height': height,
      'weight': weight,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? pseudo,
    String? photoUrl,
    int? age,
    String? gender,
    String? location,
    int? dailyGoal,
    DateTime? createdAt,
    String? userLevel,
    List<String>? groupIds,
    List<String>? badges,
    int? totalSteps,
    int? totalDistance,
    int? totalCalories,
    double? height,
    double? weight,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      pseudo: pseudo ?? this.pseudo,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      createdAt: createdAt ?? this.createdAt,
      userLevel: userLevel ?? this.userLevel,
      groupIds: groupIds ?? this.groupIds,
      badges: badges ?? this.badges,
      totalSteps: totalSteps ?? this.totalSteps,
      totalDistance: totalDistance ?? this.totalDistance,
      totalCalories: totalCalories ?? this.totalCalories,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}

