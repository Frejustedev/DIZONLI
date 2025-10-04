import 'package:flutter/foundation.dart';
import '../models/stats_model.dart';
import '../services/analytics_service.dart';

/// Provider pour gérer l'état des analytics et statistiques
class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  PeriodStatsModel? _weeklyStats;
  PeriodStatsModel? _monthlyStats;
  List<UserInsight> _insights = [];
  List<PerformanceComparison> _comparisons = [];
  List<ChartDataPoint> _weeklyChartData = [];
  List<ChartDataPoint> _monthlyChartData = [];
  ActivityDistribution? _hourlyDistribution;
  bool _isLoading = false;
  String? _error;

  // Getters
  PeriodStatsModel? get weeklyStats => _weeklyStats;
  PeriodStatsModel? get monthlyStats => _monthlyStats;
  List<UserInsight> get insights => _insights;
  List<PerformanceComparison> get comparisons => _comparisons;
  List<ChartDataPoint> get weeklyChartData => _weeklyChartData;
  List<ChartDataPoint> get monthlyChartData => _monthlyChartData;
  ActivityDistribution? get hourlyDistribution => _hourlyDistribution;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge toutes les statistiques pour un utilisateur
  Future<void> loadAllStats(String userId, int dailyGoal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Statistiques hebdomadaires
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      _weeklyStats = await _analyticsService.getPeriodStats(
        userId,
        weekStart,
        now,
        dailyGoal,
      );

      // Statistiques mensuelles
      final monthStart = DateTime(now.year, now.month, 1);
      _monthlyStats = await _analyticsService.getPeriodStats(
        userId,
        monthStart,
        now,
        dailyGoal,
      );

      // Données pour graphiques
      _weeklyChartData = await _analyticsService.getChartData(
        userId,
        weekStart,
        now,
      );

      _monthlyChartData = await _analyticsService.getChartData(
        userId,
        monthStart,
        now,
      );

      // Insights personnalisés
      _insights = await _analyticsService.generateInsights(userId, dailyGoal);

      // Comparaisons de performances
      _comparisons = await _analyticsService.getPerformanceComparisons(userId, dailyGoal);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge uniquement les statistiques hebdomadaires
  Future<void> loadWeeklyStats(String userId, int dailyGoal) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      _weeklyStats = await _analyticsService.getPeriodStats(
        userId,
        weekStart,
        now,
        dailyGoal,
      );

      _weeklyChartData = await _analyticsService.getChartData(
        userId,
        weekStart,
        now,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Charge uniquement les insights
  Future<void> loadInsights(String userId, int dailyGoal) async {
    try {
      _insights = await _analyticsService.generateInsights(userId, dailyGoal);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Charge la répartition horaire d'activité
  Future<void> loadHourlyDistribution(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: 7));

      _hourlyDistribution = await _analyticsService.getHourlyDistribution(
        userId,
        weekStart,
        now,
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Prédit les pas de fin de journée
  int predictEndOfDaySteps(int currentSteps) {
    final now = DateTime.now();
    return _analyticsService.predictDailySteps(currentSteps, now);
  }

  /// Calcule la progression
  double calculateProgress(int current, int goal) {
    return _analyticsService.calculateProgress(current, goal);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

