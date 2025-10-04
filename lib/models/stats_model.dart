import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour les statistiques d'un utilisateur
class UserStatsModel {
  final String userId;
  final DateTime date;
  final int steps;
  final double distance; // en km
  final double calories; // en kcal
  final int activeMinutes;
  final Map<String, int> hourlySteps; // Steps par heure de la journée
  final DateTime createdAt;

  UserStatsModel({
    required this.userId,
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    this.activeMinutes = 0,
    this.hourlySteps = const {},
    required this.createdAt,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      steps: json['steps'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      activeMinutes: json['activeMinutes'] ?? 0,
      hourlySteps: json['hourlySteps'] != null
          ? Map<String, int>.from(json['hourlySteps'])
          : {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'activeMinutes': activeMinutes,
      'hourlySteps': hourlySteps,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Statistiques agrégées sur une période
class PeriodStatsModel {
  final DateTime startDate;
  final DateTime endDate;
  final int totalSteps;
  final double totalDistance;
  final double totalCalories;
  final int totalActiveMins;
  final double averageSteps;
  final int bestDay;
  final int worstDay;
  final int daysActive;
  final int goalReachedCount;

  PeriodStatsModel({
    required this.startDate,
    required this.endDate,
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCalories,
    required this.totalActiveMins,
    required this.averageSteps,
    required this.bestDay,
    required this.worstDay,
    required this.daysActive,
    required this.goalReachedCount,
  });

  double get completion => daysActive > 0 ? (goalReachedCount / daysActive) * 100 : 0;
}

/// Insights personnalisés pour l'utilisateur
enum InsightType {
  streak,          // Série de jours consécutifs
  improvement,     // Amélioration récente
  warning,         // Baisse d'activité
  achievement,     // Accomplissement remarquable
  suggestion,      // Suggestion personnalisée
}

class UserInsight {
  final InsightType type;
  final String title;
  final String message;
  final String? actionText;
  final DateTime createdAt;

  UserInsight({
    required this.type,
    required this.title,
    required this.message,
    this.actionText,
    required this.createdAt,
  });

  String getIcon() {
    switch (type) {
      case InsightType.streak:
        return '🔥';
      case InsightType.improvement:
        return '📈';
      case InsightType.warning:
        return '⚠️';
      case InsightType.achievement:
        return '🎉';
      case InsightType.suggestion:
        return '💡';
    }
  }
}

/// Comparaison de performances
class PerformanceComparison {
  final String label;
  final int currentValue;
  final int previousValue;
  final double percentageChange;

  PerformanceComparison({
    required this.label,
    required this.currentValue,
    required this.previousValue,
  }) : percentageChange = previousValue > 0
            ? ((currentValue - previousValue) / previousValue) * 100
            : 0;

  bool get isImprovement => percentageChange > 0;
  bool get isDecline => percentageChange < 0;
  bool get isStable => percentageChange == 0;
}

/// Données pour les graphiques
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

/// Répartition d'activité (par heure, jour de semaine, etc.)
class ActivityDistribution {
  final Map<String, int> distribution; // Clé: période, Valeur: steps
  final String mostActiveTime;
  final String leastActiveTime;

  ActivityDistribution({
    required this.distribution,
    required this.mostActiveTime,
    required this.leastActiveTime,
  });
}

