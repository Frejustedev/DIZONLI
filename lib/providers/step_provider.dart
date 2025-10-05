import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/step_counter_service.dart';
import '../services/step_service.dart';
import '../services/background_step_sync_service.dart';

class StepProvider with ChangeNotifier {
  final StepCounterService _stepService = StepCounterService();
  final StepService _firestoreStepService = StepService();
  final BackgroundStepSyncService _backgroundSync = BackgroundStepSyncService();
  
  int _steps = 0;
  bool _isInitialized = false;
  String? _currentUserId;
  Timer? _saveTimer;
  Timer? _systemStepsRefreshTimer;
  int _lastSavedSteps = 0;
  bool _useSystemSteps = false; // Utiliser Google Fit / Health Connect

  int get steps => _steps;
  bool get isInitialized => _isInitialized;
  bool get usingSystemSteps => _useSystemSteps;
  
  double get distance => _stepService.getDistanceInKm();
  int get calories => _stepService.getCalories();
  
  double getProgress(int goal) => _stepService.getProgress(goal);

  // Initialize step counter
  Future<void> initialize({String? userId}) async {
    if (_isInitialized && userId == _currentUserId) return;
    
    _currentUserId = userId;
    
    // Essayer d'utiliser le système (Google Fit / Health Connect) en priorité
    if (_currentUserId != null && !kIsWeb) {
      try {
        await _backgroundSync.startPeriodicSync(_currentUserId!);
        _useSystemSteps = true;
        debugPrint('✅ Utilisation de Google Fit / Health Connect');
        
        // Rafraîchir les pas du système toutes les 5 minutes
        _startSystemStepsRefresh();
      } catch (e) {
        debugPrint('⚠️ Impossible d\'utiliser le système, fallback sur capteur: $e');
        _useSystemSteps = false;
      }
    }
    
    // Fallback: utiliser le capteur local si le système n'est pas disponible
    if (!_useSystemSteps) {
      await _stepService.initialize();
      _startListening();
      _startAutoSave();
    }
    
    // Charger les pas du jour depuis Firestore
    if (_currentUserId != null) {
      await _loadTodayStepsFromFirestore();
    }
    
    _isInitialized = true;
  }
  
  // Rafraîchir les pas du système périodiquement
  void _startSystemStepsRefresh() {
    _systemStepsRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) async {
        if (_useSystemSteps) {
          final systemSteps = await _backgroundSync.getTodaySteps();
          if (systemSteps > 0 && systemSteps != _steps) {
            _steps = systemSteps;
            notifyListeners();
            debugPrint('🔄 Pas mis à jour depuis le système: $systemSteps');
          }
        }
      },
    );
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
      if (_useSystemSteps) {
        await _backgroundSync.forceSyncNow();
      } else {
        await _saveStepsToFirestore();
      }
    }
  }
  
  // Synchroniser l'historique depuis le système
  Future<void> syncHistoricalData(int days) async {
    if (_currentUserId != null && _useSystemSteps) {
      await _backgroundSync.syncHistory(days);
      notifyListeners();
    }
  }
  
  // Obtenir les pas actuels depuis le système
  Future<void> refreshFromSystem() async {
    if (_useSystemSteps) {
      final systemSteps = await _backgroundSync.getTodaySteps();
      if (systemSteps >= 0) {
        _steps = systemSteps;
        notifyListeners();
      }
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
    _systemStepsRefreshTimer?.cancel();
    if (_useSystemSteps) {
      _backgroundSync.stopPeriodicSync();
    }
    _isInitialized = false;
    super.dispose();
  }
}

