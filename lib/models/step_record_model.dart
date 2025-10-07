import 'package:cloud_firestore/cloud_firestore.dart';

class StepRecordModel {
  final String id;
  final String userId;
  final int steps;
  final double distance; // in meters
  final int calories;
  final DateTime date;
  final DateTime timestamp;

  StepRecordModel({
    required this.id,
    required this.userId,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.date,
    required this.timestamp,
  });

  factory StepRecordModel.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour convertir Timestamp ou String en DateTime
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return StepRecordModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      steps: (json['steps'] ?? 0).toInt(),
      distance: (json['distance'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toInt(),
      date: _parseDate(json['date']),
      timestamp: _parseDate(json['timestamp'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'date': date.toIso8601String().split('T')[0],
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Calculate calories burned (rough estimate: 0.04 calories per step)
  static int calculateCalories(int steps) {
    return (steps * 0.04).round();
  }

  // Calculate distance (rough estimate: 0.762 meters per step)
  static double calculateDistance(int steps) {
    return steps * 0.762;
  }
}

