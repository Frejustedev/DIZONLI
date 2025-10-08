import 'package:flutter/material.dart';
import '../models/step_record_model.dart';

/// Widget simplifié d'histogrammes garantis visibles
class SimpleWeeklyHistograms extends StatelessWidget {
  final List<StepRecordModel> weekData;
  final int dailyGoal;

  const SimpleWeeklyHistograms({
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
          child: _buildStepsCard(),
        ),
        const SizedBox(width: 12),
        // Carte Distance
        Expanded(
          child: _buildDistanceCard(),
        ),
      ],
    );
  }

  Widget _buildStepsCard() {
    final todaySteps = _getTodaySteps(weekData);
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.directions_walk,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pas',
                    style: TextStyle(
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
            
            // Today label
            Text(
              'Auj.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            
            // Today value
            Text(
              todaySteps.toString(),
              style: const TextStyle(
                color: Color(0xFF9C27B0),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Bar chart
            Expanded(
      child: _buildBars(
        const Color(0xFF9C27B0),
        (record) => record.steps.toDouble(),
        _getMaxSteps(weekData, dailyGoal),
        weekData,
      ),
            ),
            const SizedBox(height: 8),
            
            // Days labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('L', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('M', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('M', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('J', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('V', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('S', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('D', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceCard() {
    final todayDistance = _getTodayDistance(weekData);
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Distance',
                    style: TextStyle(
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
            
            // Today label
            Text(
              'Auj.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            
            // Today value
            Text(
              '${todayDistance.toStringAsFixed(2)}km',
              style: const TextStyle(
                color: Color(0xFF03A9F4),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Bar chart
            Expanded(
      child: _buildBars(
        const Color(0xFF03A9F4),
        (record) => record.distance,
        _getMaxDistance(weekData),
        weekData,
      ),
            ),
            const SizedBox(height: 8),
            
            // Days labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('L', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('M', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('M', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('J', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('V', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('S', style: TextStyle(color: Colors.white38, fontSize: 10)),
                Text('D', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBars(
    Color color,
    double Function(StepRecordModel) getValue,
    double maxY,
    List<StepRecordModel> weekData,
  ) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
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
        final height = maxY > 0 ? (value / maxY) * 100 : 5.0;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Valeur au-dessus de la barre
              if (value > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _formatValue(value),
                    style: TextStyle(
                      color: isToday ? color : Colors.white38,
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                const SizedBox(height: 13), // Pour garder l'alignement
              
              // Barre
              Container(
                width: 8,
                height: height.clamp(5.0, 100.0),
                decoration: BoxDecoration(
                  color: isToday ? color : color.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (value >= 100) {
      return value.toInt().toString();
    } else if (value >= 10) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  int _getTodaySteps(List<StepRecordModel> weekData) {
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

  double _getTodayDistance(List<StepRecordModel> weekData) {
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

  double _getMaxSteps(List<StepRecordModel> weekData, int dailyGoal) {
    if (weekData.isEmpty) return dailyGoal.toDouble();
    
    final maxSteps = weekData.fold<int>(
      0,
      (max, record) => record.steps > max ? record.steps : max,
    );
    
    final maxValue = maxSteps > dailyGoal ? maxSteps : dailyGoal;
    return maxValue.toDouble();
  }

  double _getMaxDistance(List<StepRecordModel> weekData) {
    if (weekData.isEmpty) return 10.0;
    
    final maxDistance = weekData.fold<double>(
      0,
      (max, record) => record.distance > max ? record.distance : max,
    );
    
    return maxDistance > 0 ? maxDistance * 1.2 : 10.0;
  }
}

