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
    return StepRecordModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      steps: json['steps'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      calories: json['calories'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
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

