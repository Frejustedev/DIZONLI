import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/step_service.dart';
import '../../models/step_record_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StepService _stepService = StepService();
  
  List<StepRecordModel> _records = [];
  bool _isLoading = true;
  
  // Statistiques calculées
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final userProvider = context.read<UserProvider>();
    if (userProvider.currentUser == null) return;
    
    final userId = userProvider.currentUser!.id;
    
    try {
      // Charger tous les enregistrements
      final allRecords = await _stepService.getAllStepRecords(userId);
      
      setState(() {
        _records = allRecords;
        _calculateStatistics();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _calculateStatistics() {
    if (_records.isEmpty) {
      _stats = {
        'totalSteps': 0,
        'totalDistance': 0.0,
        'totalCalories': 0.0,
        'averageSteps': 0,
        'bestDay': null,
        'bestWeek': null,
        'bestMonth': null,
        'currentStreak': 0,
        'longestStreak': 0,
      };
      return;
    }

    // Calculer les statistiques globales
    int totalSteps = 0;
    double totalDistance = 0.0;
    double totalCalories = 0.0;
    
    StepRecordModel? bestDayRecord;
    int maxDaySteps = 0;
    
    // Analyser chaque enregistrement
    for (var record in _records) {
      totalSteps += record.steps;
      totalDistance += record.distance;
      totalCalories += record.calories;
      
      // Meilleur jour
      if (record.steps > maxDaySteps) {
        maxDaySteps = record.steps;
        bestDayRecord = record;
      }
    }
    
    // Calculer les moyennes
    int averageSteps = (_records.isNotEmpty) ? (totalSteps / _records.length).round() : 0;
    
    // Calculer les séries (streaks)
    int currentStreak = _calculateCurrentStreak();
    int longestStreak = _calculateLongestStreak();
    
    // Meilleur mois et semaine
    var bestMonth = _findBestMonth();
    var bestWeek = _findBestWeek();
    
    _stats = {
      'totalSteps': totalSteps,
      'totalDistance': totalDistance,
      'totalCalories': totalCalories,
      'averageSteps': averageSteps,
      'bestDay': bestDayRecord,
      'bestWeek': bestWeek,
      'bestMonth': bestMonth,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalDays': _records.length,
    };
  }

  int _calculateCurrentStreak() {
    if (_records.isEmpty) return 0;
    
    // Trier par date décroissante
    var sortedRecords = List<StepRecordModel>.from(_records);
    sortedRecords.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    for (var record in sortedRecords) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      final targetDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
      
      if (recordDate == targetDate && record.steps > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (recordDate.isBefore(targetDate)) {
        break;
      }
    }
    
    return streak;
  }

  int _calculateLongestStreak() {
    if (_records.isEmpty) return 0;
    
    var sortedRecords = List<StepRecordModel>.from(_records);
    sortedRecords.sort((a, b) => a.date.compareTo(b.date));
    
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (var record in sortedRecords) {
      if (record.steps == 0) {
        currentStreak = 0;
        lastDate = null;
        continue;
      }
      
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final dayDiff = record.date.difference(lastDate).inDays;
        if (dayDiff == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      
      maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      lastDate = record.date;
    }
    
    return maxStreak;
  }

  Map<String, dynamic>? _findBestWeek() {
    if (_records.isEmpty) return null;
    
    Map<int, Map<String, dynamic>> weeklyStats = {};
    
    for (var record in _records) {
      // Calculer le numéro de semaine
      int weekNumber = _getWeekNumber(record.date);
      int year = record.date.year;
      String weekKey = '$year-W$weekNumber';
      
      if (!weeklyStats.containsKey(weekKey.hashCode)) {
        weeklyStats[weekKey.hashCode] = {
          'week': weekKey,
          'steps': 0,
          'distance': 0.0,
          'calories': 0.0,
          'startDate': record.date,
        };
      }
      
      weeklyStats[weekKey.hashCode]!['steps'] += record.steps;
      weeklyStats[weekKey.hashCode]!['distance'] += record.distance;
      weeklyStats[weekKey.hashCode]!['calories'] += record.calories;
    }
    
    if (weeklyStats.isEmpty) return null;
    
    // Trouver la meilleure semaine
    var bestWeek = weeklyStats.values.reduce((a, b) => 
      (a['steps'] as int) > (b['steps'] as int) ? a : b
    );
    
    return bestWeek;
  }

  Map<String, dynamic>? _findBestMonth() {
    if (_records.isEmpty) return null;
    
    Map<String, Map<String, dynamic>> monthlyStats = {};
    
    for (var record in _records) {
      String monthKey = DateFormat('yyyy-MM').format(record.date);
      
      if (!monthlyStats.containsKey(monthKey)) {
        monthlyStats[monthKey] = {
          'month': monthKey,
          'steps': 0,
          'distance': 0.0,
          'calories': 0.0,
        };
      }
      
      monthlyStats[monthKey]!['steps'] += record.steps;
      monthlyStats[monthKey]!['distance'] += record.distance;
      monthlyStats[monthKey]!['calories'] += record.calories;
    }
    
    if (monthlyStats.isEmpty) return null;
    
    // Trouver le meilleur mois
    var bestMonth = monthlyStats.values.reduce((a, b) => 
      (a['steps'] as int) > (b['steps'] as int) ? a : b
    );
    
    return bestMonth;
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Jour'),
            Tab(text: 'Semaine'),
            Tab(text: 'Mois'),
            Tab(text: 'Records'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDayTab(),
                _buildWeekTab(),
                _buildMonthTab(),
                _buildRecordsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartes de statistiques globales
            _buildGlobalStatsCards(),
            const SizedBox(height: 24),
            
            // Graphique de tendance
            _buildTrendChart(),
            const SizedBox(height: 24),
            
            // Séries (Streaks)
            _buildStreaksSection(),
            const SizedBox(height: 24),
            
            // Comparaison périodes
            _buildPeriodComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Depuis toujours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total de pas',
                _formatNumber(_stats['totalSteps'] ?? 0),
                Icons.directions_walk,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Jours actifs',
                '${_stats['totalDays'] ?? 0}',
                Icons.calendar_today,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Distance totale',
                '${(_stats['totalDistance'] ?? 0.0).toStringAsFixed(1)} km',
                Icons.straighten,
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Calories brûlées',
                '${(_stats['totalCalories'] ?? 0.0).toStringAsFixed(0)} kcal',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Moyenne quotidienne',
          '${_formatNumber(_stats['averageSteps'] ?? 0)} pas/jour',
          Icons.insights,
          Colors.purple,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (fullWidth) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!fullWidth) ...[
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    if (_records.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Prendre les 30 derniers jours
    var recentRecords = List<StepRecordModel>.from(_records);
    recentRecords.sort((a, b) => b.date.compareTo(a.date));
    recentRecords = recentRecords.take(30).toList().reversed.toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendance - 30 derniers jours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value.toInt()),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= recentRecords.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          DateFormat('dd/MM').format(recentRecords[value.toInt()].date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: recentRecords
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.steps.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔥 Séries d\'activité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_stats['currentStreak'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Jours consécutifs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white30,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_stats['longestStreak'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Record',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vos records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Meilleur jour
        if (_stats['bestDay'] != null)
          _buildRecordCard(
            '🏆 Meilleur jour',
            '${_formatNumber(_stats['bestDay'].steps)} pas',
            DateFormat('dd MMMM yyyy', 'fr_FR').format(_stats['bestDay'].date),
            AppColors.primary,
          ),
        const SizedBox(height: 12),
        
        // Meilleure semaine
        if (_stats['bestWeek'] != null)
          _buildRecordCard(
            '📅 Meilleure semaine',
            '${_formatNumber(_stats['bestWeek']['steps'])} pas',
            _stats['bestWeek']['week'],
            AppColors.secondary,
          ),
        const SizedBox(height: 12),
        
        // Meilleur mois
        if (_stats['bestMonth'] != null)
          _buildRecordCard(
            '📆 Meilleur mois',
            '${_formatNumber(_stats['bestMonth']['steps'])} pas',
            DateFormat('MMMM yyyy', 'fr_FR').format(DateTime.parse(_stats['bestMonth']['month'] + '-01')),
            AppColors.accent,
          ),
      ],
    );
  }

  Widget _buildRecordCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTab() {
    return const Center(
      child: Text('Vue journalière - À implémenter'),
    );
  }

  Widget _buildWeekTab() {
    return const Center(
      child: Text('Vue hebdomadaire - À implémenter'),
    );
  }

  Widget _buildMonthTab() {
    return const Center(
      child: Text('Vue mensuelle avec calendrier - À implémenter'),
    );
  }

  Widget _buildRecordsTab() {
    return const Center(
      child: Text('Tous les records - À implémenter'),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

