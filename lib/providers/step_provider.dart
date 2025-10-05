import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/step_counter_service.dart';
import '../services/step_service.dart';

class StepProvider with ChangeNotifier {
  final StepCounterService _stepService = StepCounterService();
  final StepService _firestoreStepService = StepService();
  int _steps = 0;
  bool _isInitialized = false;
  String? _currentUserId;
  Timer? _saveTimer;
  int _lastSavedSteps = 0;

  int get steps => _steps;
  bool get isInitialized => _isInitialized;
  
  double get distance => _stepService.getDistanceInKm();
  int get calories => _stepService.getCalories();
  
  double getProgress(int goal) => _stepService.getProgress(goal);

  // Initialize step counter
  Future<void> initialize({String? userId}) async {
    if (_isInitialized && userId == _currentUserId) return;
    
    _currentUserId = userId;
    await _stepService.initialize();
    _isInitialized = true;
    
    // Charger les pas du jour depuis Firestore
    if (_currentUserId != null) {
      await _loadTodayStepsFromFirestore();
    }
    
    // Start listening to step updates
    _startListening();
    
    // Start auto-save timer (save every 2 minutes)
    _startAutoSave();
  }

  // Charger les pas du jour depuis Firestore
  Future<void> _loadTodayStepsFromFirestore() async {
    if (_currentUserId == null) return;
    
    try {
      final todayRecord = await _firestoreStepService.getStepsByDate(
        _currentUserId!,
        DateTime.now(),
      );
      
      if (todayRecord != null) {
        _lastSavedSteps = todayRecord.steps;
        debugPrint('✅ Pas chargés depuis Firestore: ${todayRecord.steps}');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des pas: $e');
    }
  }

  // Listen to step updates
  void _startListening() {
    // Update steps every second
    Future.delayed(const Duration(seconds: 1), () {
      if (_isInitialized) {
        final newSteps = _stepService.todaySteps;
        if (newSteps != _steps) {
          _steps = newSteps;
          notifyListeners();
          
          // Sauvegarde immédiate si changement significatif (>= 10 pas)
          if (_currentUserId != null && (_steps - _lastSavedSteps) >= 10) {
            _saveStepsToFirestore();
          }
        }
        _startListening();
      }
    });
  }

  // Start auto-save timer
  void _startAutoSave() {
    _saveTimer?.cancel();
    
    // Sauvegarder toutes les 2 minutes
    _saveTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_currentUserId != null && _steps != _lastSavedSteps) {
        _saveStepsToFirestore();
      }
    });
  }

  // Sauvegarder les pas dans Firestore
  Future<void> _saveStepsToFirestore() async {
    if (_currentUserId == null || _steps == 0) return;
    
    try {
      await _firestoreStepService.saveSteps(
        _currentUserId!,
        _steps,
        DateTime.now(),
      );
      _lastSavedSteps = _steps;
      debugPrint('✅ Pas sauvegardés dans Firestore: $_steps');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des pas: $e');
    }
  }

  // Forcer la sauvegarde (appelé manuellement si nécessaire)
  Future<void> forceSave() async {
    if (_currentUserId != null) {
      await _saveStepsToFirestore();
    }
  }

  // Reset steps
  Future<void> resetSteps() async {
    await _stepService.resetSteps();
    _steps = 0;
    _lastSavedSteps = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _isInitialized = false;
    super.dispose();
  }
}

