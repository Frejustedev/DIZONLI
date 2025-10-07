import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/step_record_model.dart';

/// Widget de graphique style Google Fit pour afficher les pas et distance de la semaine
class GoogleFitWeeklyChart extends StatelessWidget {
  final List<StepRecordModel> weekData;
  final int dailyGoal;

  const GoogleFitWeeklyChart({
    super.key,
    required this.weekData,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Carte Pas
        Expanded(
          child: _buildChart(
            title: 'Pas',
            icon: Icons.directions_walk,
            color: const Color(0xFF9C27B0), // Violet comme Google Fit
            getValue: (record) => record.steps.toDouble(),
            formatValue: (value) => value.toInt().toString(),
            todayValue: _getTodaySteps().toString(),
            maxY: _getMaxSteps(),
          ),
        ),
        const SizedBox(width: 12),
        // Carte Distance
        Expanded(
          child: _buildChart(
            title: 'Distance',
            icon: Icons.straighten,
            color: const Color(0xFF03A9F4), // Bleu comme Google Fit
            getValue: (record) => record.distance,
            formatValue: (value) => '${value.toStringAsFixed(1)}km',
            todayValue: '${_getTodayDistance().toStringAsFixed(2)}km',
            maxY: _getMaxDistance(),
          ),
        ),
      ],
    );
  }

  Widget _buildChart({
    required String title,
    required IconData icon,
    required Color color,
    required double Function(StepRecordModel) getValue,
    required String Function(double) formatValue,
    required String todayValue,
    required double maxY,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Fond sombre comme Google Fit
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec icône et titre
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Valeur du jour (Today)
            Text(
              'Auj.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              todayValue,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Histogramme
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = _getDayName(groupIndex);
                        return BarTooltipItem(
                          '$day\n${formatValue(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _getDayInitial(value.toInt()),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _getBarGroups(getValue, color),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Légende des heures
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lun',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                  ),
                ),
                Text(
                  'Dim',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(
    double Function(StepRecordModel) getValue,
    Color color,
  ) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final record = weekData.firstWhere(
        (r) => _isSameDay(r.date, date),
        orElse: () => StepRecordModel(
          id: '',
          userId: '',
          date: date,
          timestamp: date,
          steps: 0,
          distance: 0,
          calories: 0,
        ),
      );

      final value = getValue(record);
      final isToday = _isSameDay(date, today);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value == 0 ? 0.1 : value, // Minimum pour visibilité
            color: isToday ? color : color.withOpacity(0.5),
            width: 8,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(3),
            ),
          ),
        ],
      );
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayInitial(int index) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[index];
  }

  String _getDayName(int index) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[index];
  }

  double _getMaxSteps() {
    if (weekData.isEmpty) return dailyGoal.toDouble() * 1.2;
    
    final maxSteps = weekData.fold<int>(
      0,
      (max, record) => record.steps > max ? record.steps : max,
    );
    
    final maxValue = maxSteps > dailyGoal ? maxSteps : dailyGoal;
    return (maxValue * 1.2).roundToDouble();
  }

  double _getMaxDistance() {
    if (weekData.isEmpty) return 10.0;
    
    final maxDistance = weekData.fold<double>(
      0,
      (max, record) => record.distance > max ? record.distance : max,
    );
    
    return (maxDistance * 1.3);
  }

  int _getTodaySteps() {
    final today = DateTime.now();
    final todayRecord = weekData.firstWhere(
      (r) => _isSameDay(r.date, today),
      orElse: () => StepRecordModel(
        id: '',
        userId: '',
        date: today,
        timestamp: today,
        steps: 0,
        distance: 0,
        calories: 0,
      ),
    );
    return todayRecord.steps;
  }

  double _getTodayDistance() {
    final today = DateTime.now();
    final todayRecord = weekData.firstWhere(
      (r) => _isSameDay(r.date, today),
      orElse: () => StepRecordModel(
        id: '',
        userId: '',
        date: today,
        timestamp: today,
        steps: 0,
        distance: 0,
        calories: 0,
      ),
    );
    return todayRecord.distance;
  }
}

