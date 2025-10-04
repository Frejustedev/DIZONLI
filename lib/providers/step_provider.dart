import 'package:flutter/foundation.dart';
import '../services/step_counter_service.dart';

class StepProvider with ChangeNotifier {
  final StepCounterService _stepService = StepCounterService();
  int _steps = 0;
  bool _isInitialized = false;

  int get steps => _steps;
  bool get isInitialized => _isInitialized;
  
  double get distance => _stepService.getDistanceInKm();
  int get calories => _stepService.getCalories();
  
  double getProgress(int goal) => _stepService.getProgress(goal);

  // Initialize step counter
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _stepService.initialize();
    _isInitialized = true;
    
    // Start listening to step updates
    _startListening();
  }

  // Listen to step updates
  void _startListening() {
    // Update steps every second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isInitialized) {
        _steps = _stepService.todaySteps;
        notifyListeners();
        _startListening();
      }
    });
  }

  // Reset steps
  Future<void> resetSteps() async {
    await _stepService.resetSteps();
    _steps = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _isInitialized = false;
    super.dispose();
  }
}

