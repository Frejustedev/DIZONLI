import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stats_model.dart';
import '../models/step_record_model.dart';
import 'firestore_service.dart';

/// Service pour gérer les analytics et statistiques avancées
class AnalyticsService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calcule les statistiques pour une période donnée
  Future<PeriodStatsModel> getPeriodStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
    int dailyGoal,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('steps')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      if (snapshot.docs.isEmpty) {
        return PeriodStatsModel(
          startDate: startDate,
          endDate: endDate,
          totalSteps: 0,
          totalDistance: 0,
          totalCalories: 0,
          totalActiveMins: 0,
          averageSteps: 0,
          bestDay: 0,
          worstDay: 0,
          daysActive: 0,
          goalReachedCount: 0,
        );
      }

      final records = snapshot.docs
          .map((doc) => StepRecordModel.fromJson(doc.data()))
          .toList();

      int totalSteps = 0;
      double totalDistance = 0;
      double totalCalories = 0;
      int bestDay = 0;
      int worstDay = records.first.steps;
      int goalReachedCount = 0;

      for (var record in records) {
        totalSteps += record.steps.toInt();
        totalDistance += record.distance;
        totalCalories += record.calories;

        if (record.steps > bestDay) bestDay = record.steps;
        if (record.steps < worstDay) worstDay = record.steps;
        if (record.steps >= dailyGoal) goalReachedCount++;
      }

      return PeriodStatsModel(
        startDate: startDate,
        endDate: endDate,
        totalSteps: totalSteps,
        totalDistance: totalDistance,
        totalCalories: totalCalories,
        totalActiveMins: 0,
        averageSteps: records.isNotEmpty ? totalSteps / records.length : 0,
        bestDay: bestDay,
        worstDay: worstDay,
        daysActive: records.length,
        goalReachedCount: goalReachedCount,
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// Récupère les données pour un graphique sur une période
  Future<List<ChartDataPoint>> getChartData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('steps')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) {
            final record = StepRecordModel.fromJson(doc.data());
            return ChartDataPoint(
              date: record.date,
              value: record.steps.toDouble(),
              label: '${record.date.day}/${record.date.month}',
            );
          })
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données du graphique: $e');
    }
  }

  /// Génère des insights personnalisés basés sur les données de l'utilisateur
  Future<List<UserInsight>> generateInsights(
    String userId,
    int dailyGoal,
  ) async {
    final insights = <UserInsight>[];
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last14Days = now.subtract(const Duration(days: 14));

    try {
      // Récupère les stats des 14 derniers jours
      final thisWeekStats = await getPeriodStats(userId, last7Days, now, dailyGoal);
      final lastWeekStats = await getPeriodStats(
        userId,
        last14Days,
        last7Days,
        dailyGoal,
      );

      // Insight 1: Série de jours consécutifs
      final streak = await _calculateStreak(userId, dailyGoal);
      if (streak >= 3) {
        insights.add(UserInsight(
          type: InsightType.streak,
          title: 'Série en cours !',
          message: 'Vous avez atteint votre objectif $streak jours de suite ! Continuez comme ça !',
          actionText: 'Voir mon historique',
          createdAt: now,
        ));
      }

      // Insight 2: Amélioration
      if (thisWeekStats.averageSteps > lastWeekStats.averageSteps * 1.1) {
        final improvement = ((thisWeekStats.averageSteps - lastWeekStats.averageSteps) /
                lastWeekStats.averageSteps *
                100)
            .round();
        insights.add(UserInsight(
          type: InsightType.improvement,
          title: 'Belle progression !',
          message: 'Vous marchez $improvement% de plus que la semaine dernière. Excellent travail !',
          actionText: 'Voir mes statistiques',
          createdAt: now,
        ));
      }

      // Insight 3: Avertissement de baisse
      if (thisWeekStats.averageSteps < lastWeekStats.averageSteps * 0.8 &&
          lastWeekStats.averageSteps > 0) {
        insights.add(UserInsight(
          type: InsightType.warning,
          title: 'Activité en baisse',
          message: 'Votre activité a diminué cette semaine. Fixez-vous un défi pour repartir du bon pied !',
          actionText: 'Voir les défis',
          createdAt: now,
        ));
      }

      // Insight 4: Accomplissement remarquable
      if (thisWeekStats.bestDay >= dailyGoal * 1.5) {
        insights.add(UserInsight(
          type: InsightType.achievement,
          title: 'Record personnel !',
          message: 'Vous avez atteint ${thisWeekStats.bestDay} pas en une journée ! C\'est 50% au-dessus de votre objectif !',
          actionText: null,
          createdAt: now,
        ));
      }

      // Insight 5: Suggestion personnalisée
      if (thisWeekStats.goalReachedCount < 3 && thisWeekStats.daysActive >= 5) {
        final avgShortfall = dailyGoal - thisWeekStats.averageSteps.round();
        if (avgShortfall > 0) {
          insights.add(UserInsight(
            type: InsightType.suggestion,
            title: 'Petit effort supplémentaire',
            message: 'Il vous manque en moyenne $avgShortfall pas par jour pour atteindre votre objectif. Une marche de 15 minutes suffirait !',
            actionText: 'Ajuster mon objectif',
            createdAt: now,
          ));
        }
      }

      return insights;
    } catch (e) {
      return [];
    }
  }

  /// Calcule la série de jours consécutifs où l'objectif a été atteint
  Future<int> _calculateStreak(String userId, int dailyGoal) async {
    try {
      final now = DateTime.now();
      int streak = 0;

      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final docId = '${userId}_$dateStr';

        final doc = await _firestore.collection('steps').doc(docId).get();

        if (doc.exists) {
          final record = StepRecordModel.fromJson(doc.data()!);
          if (record.steps >= dailyGoal) {
            streak++;
          } else {
            break;
          }
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  /// Compare les performances actuelles avec les précédentes
  Future<List<PerformanceComparison>> getPerformanceComparisons(
    String userId,
    int dailyGoal,
  ) async {
    final comparisons = <PerformanceComparison>[];
    final now = DateTime.now();

    try {
      // Cette semaine vs semaine dernière
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekStats = await getPeriodStats(userId, thisWeekStart, now, dailyGoal);

      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
      final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
      final lastWeekStats = await getPeriodStats(userId, lastWeekStart, lastWeekEnd, dailyGoal);

      comparisons.add(PerformanceComparison(
        label: 'Pas cette semaine',
        currentValue: thisWeekStats.totalSteps,
        previousValue: lastWeekStats.totalSteps,
      ));

      comparisons.add(PerformanceComparison(
        label: 'Moyenne quotidienne',
        currentValue: thisWeekStats.averageSteps.round(),
        previousValue: lastWeekStats.averageSteps.round(),
      ));

      comparisons.add(PerformanceComparison(
        label: 'Objectifs atteints',
        currentValue: thisWeekStats.goalReachedCount,
        previousValue: lastWeekStats.goalReachedCount,
      ));

      return comparisons;
    } catch (e) {
      return [];
    }
  }

  /// Analyse la répartition d'activité par heure de la journée
  Future<ActivityDistribution> getHourlyDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final hourlySteps = <String, int>{};

      for (int hour = 0; hour < 24; hour++) {
        hourlySteps['${hour.toString().padLeft(2, '0')}h'] = 0;
      }

      // Pour l'instant, retourne une distribution vide
      // Dans une implémentation complète, on analyserait les données horaires
      return ActivityDistribution(
        distribution: hourlySteps,
        mostActiveTime: '14h-18h',
        leastActiveTime: '00h-06h',
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'analyse de la répartition: $e');
    }
  }

  /// Calcule le pourcentage de progression vers un objectif
  double calculateProgress(int current, int goal) {
    if (goal == 0) return 0;
    return (current / goal * 100).clamp(0, 100);
  }

  /// Prédit les pas totaux de la journée basé sur l'heure actuelle
  int predictDailySteps(int currentSteps, DateTime now) {
    final hourOfDay = now.hour + now.minute / 60;
    if (hourOfDay == 0) return currentSteps;

    // Prédiction simple basée sur le taux actuel
    final stepsPerHour = currentSteps / hourOfDay;
    final predictedSteps = (stepsPerHour * 24).round();

    return predictedSteps;
  }
}

