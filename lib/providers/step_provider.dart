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
  
  // 🆕 MODE HYBRIDE : Variables pour combiner système + capteur local
  bool _hybridMode = false; // Mode hybride actif
  int _systemBaseSteps = 0; // Valeur de référence depuis Google Fit
  int _localIncrementSteps = 0; // Incrément détecté par le capteur local
  int _lastLocalSensorValue = 0; // Dernière valeur brute du capteur

  int get steps => _steps;
  bool get isInitialized => _isInitialized;
  bool get usingSystemSteps => _useSystemSteps;
  
  double get distance => _stepService.getDistanceInKm();
  int get calories => _stepService.getCalories();
  
  double getProgress(int goal) => _stepService.getProgress(goal);

  // Initialize step counter
  Future<void> initialize({String? userId, bool forceReinit = false}) async {
    if (_isInitialized && userId == _currentUserId && !forceReinit) return;
    
    // Si on force la réinitialisation, nettoyer les anciens timers
    if (forceReinit) {
      _saveTimer?.cancel();
      _systemStepsRefreshTimer?.cancel();
      _isInitialized = false;
    }
    
    _currentUserId = userId;
    
    // 🔄 MODE HYBRIDE : Essayer d'utiliser Google Fit + Capteur local simultanément
    if (_currentUserId != null && !kIsWeb) {
      try {
        debugPrint('🔄 Tentative d\'initialisation Google Fit / Health Connect...');
        await _backgroundSync.startPeriodicSync(_currentUserId!);
        _useSystemSteps = true;
        debugPrint('✅ Utilisation de Google Fit / Health Connect activée');
        
        // 🚀 SYNCHRONISATION IMMÉDIATE au démarrage
        debugPrint('🔄 Synchronisation immédiate des pas au démarrage...');
        await _backgroundSync.forceSyncNow();
        
        // Récupérer les pas du jour depuis le système (base de référence)
        final systemSteps = await _backgroundSync.getTodaySteps();
        if (systemSteps >= 0) {
          _systemBaseSteps = systemSteps;
          _steps = systemSteps;
          _localIncrementSteps = 0;
          await _stepService.setSteps(systemSteps);
          debugPrint('✅ Pas récupérés depuis le système (base): $systemSteps');
        }
        
        // 🆕 ACTIVER LE MODE HYBRIDE : Démarrer aussi le capteur local
        try {
          debugPrint('🚀 Activation du MODE HYBRIDE (Google Fit + Capteur local)...');
          await _stepService.initialize();
          _hybridMode = true;
          _startHybridListening(); // Nouvelle méthode hybride
          debugPrint('✅ MODE HYBRIDE activé avec succès!');
        } catch (e) {
          debugPrint('⚠️ Impossible d\'activer le capteur local hybride: $e');
          _hybridMode = false;
        }
        
        // Notifier les listeners pour mettre à jour l'UI
        notifyListeners();
        
        // Rafraîchir les pas du système toutes les 5 minutes
        _startHybridSystemRefresh();
      } catch (e) {
        debugPrint('⚠️ Impossible d\'utiliser le système, fallback sur capteur local: $e');
        _useSystemSteps = false;
        _hybridMode = false;
        notifyListeners();
      }
    }
    
    // Fallback : Utiliser UNIQUEMENT le capteur local si Google Fit échoue
    if (!_useSystemSteps && !kIsWeb) {
      debugPrint('🚶 Démarrage du capteur de pas local (fallback)...');
      await _stepService.initialize();
      _startListening();
      _startAutoSave();
      debugPrint('✅ Capteur de pas local démarré');
    }
    
    // Charger les pas du jour depuis Firestore
    if (_currentUserId != null) {
      await _loadTodayStepsFromFirestore();
      
      // Si on utilise le mode hybride, ajuster la base système
      if (_useSystemSteps && _hybridMode) {
        // En mode hybride, si Firestore a une valeur supérieure, l'utiliser comme base
        if (_steps > _systemBaseSteps) {
          debugPrint('ℹ️ Firestore a plus de pas ($_steps), mise à jour de la base système');
          _systemBaseSteps = _steps;
          _localIncrementSteps = 0;
          await _stepService.setSteps(_steps);
          notifyListeners();
        } else if (_systemBaseSteps > _steps) {
          debugPrint('ℹ️ Google Fit a plus de pas ($_systemBaseSteps), conservation');
          _steps = _systemBaseSteps;
          await _stepService.setSteps(_steps);
          notifyListeners();
        }
      } else if (_useSystemSteps) {
        // Mode système pur (sans hybride)
        final systemSteps = await _backgroundSync.getTodaySteps();
        if (systemSteps > _steps) {
          _steps = systemSteps;
          await _stepService.setSteps(systemSteps);
          notifyListeners();
          debugPrint('✅ Utilisation des pas Google Fit (plus récent): $systemSteps');
        } else if (_steps > 0) {
          debugPrint('ℹ️ Conservation des pas Firestore (plus récent): $_steps');
        }
      }
    }
    
    _isInitialized = true;
  }
  
  // 🆕 MODE HYBRIDE : Écouter le capteur local en temps réel
  void _startHybridListening() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (_isInitialized && _hybridMode) {
        final currentSensorValue = _stepService.todaySteps;
        
        // Première lecture : initialiser la base du capteur
        if (_lastLocalSensorValue == 0) {
          _lastLocalSensorValue = currentSensorValue;
          debugPrint('🔧 Capteur local initialisé à: $currentSensorValue');
        }
        
        // Détecter les nouveaux pas depuis la dernière lecture
        if (currentSensorValue > _lastLocalSensorValue) {
          final newSteps = currentSensorValue - _lastLocalSensorValue;
          _localIncrementSteps += newSteps;
          _lastLocalSensorValue = currentSensorValue;
          
          // Calculer le total : Base Google Fit + Incrément local
          final newTotal = _systemBaseSteps + _localIncrementSteps;
          
          if (newTotal != _steps) {
            _steps = newTotal;
            await _stepService.setSteps(_steps);
            notifyListeners();
            debugPrint('🚶 Nouveau pas détecté! Total: $_steps (base: $_systemBaseSteps + local: $_localIncrementSteps)');
            
            // Sauvegarde si changement significatif
            if (_currentUserId != null && (_steps - _lastSavedSteps) >= 10) {
              _saveStepsToFirestore();
            }
          }
        }
        
        // Continuer l'écoute
        _startHybridListening();
      }
    });
  }
  
  // 🆕 MODE HYBRIDE : Re-synchroniser avec Google Fit toutes les 5 minutes
  void _startHybridSystemRefresh() {
    _systemStepsRefreshTimer?.cancel();
    _systemStepsRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) async {
        if (_useSystemSteps && _hybridMode) {
          debugPrint('🔄 Re-synchronisation hybride avec Google Fit...');
          
          // Forcer une synchronisation avec Google Fit
          await _backgroundSync.forceSyncNow();
          final systemSteps = await _backgroundSync.getTodaySteps();
          
          debugPrint('📊 Comparaison: Google Fit=$systemSteps vs Local=$_steps (base=$_systemBaseSteps + incr=$_localIncrementSteps)');
          
          // Si Google Fit a une valeur supérieure, l'utiliser comme nouvelle base
          if (systemSteps > _steps) {
            debugPrint('✅ Google Fit est plus à jour, mise à jour de la base');
            _systemBaseSteps = systemSteps;
            _localIncrementSteps = 0;
            _lastLocalSensorValue = _stepService.todaySteps; // Réinitialiser le capteur
            _steps = systemSteps;
            await _stepService.setSteps(systemSteps);
            notifyListeners();
          } else if (_steps > systemSteps) {
            // Si le local a détecté plus de pas, sauvegarder dans Firestore
            debugPrint('ℹ️ Le capteur local a détecté plus de pas ($_steps), conservation de la valeur locale');
            // La prochaine sync Google Fit devrait récupérer ces pas
          }
          
          debugPrint('🔄 Synchronisation hybride terminée: $_steps pas');
        }
      },
    );
    
    // Démarrer aussi l'auto-save
    _startAutoSave();
  }

  // Charger les pas du jour depuis Firestore
  Future<void> _loadTodayStepsFromFirestore() async {
    if (_currentUserId == null) return;
    
    try {
      final today = DateTime.now();
      final todayRecord = await _firestoreStepService.getStepsByDate(
        _currentUserId!,
        today,
      );
      
      if (todayRecord != null && todayRecord.steps > 0) {
        _steps = todayRecord.steps; // ✅ IMPORTANT : Mettre à jour les pas affichés
        _lastSavedSteps = todayRecord.steps;
        
        // ✅ CRITIQUE : Synchroniser le StepCounterService pour que distance/calories soient calculées
        await _stepService.setSteps(todayRecord.steps);
        
        notifyListeners(); // ✅ Notifier l'UI
        debugPrint('✅ Pas chargés depuis Firestore pour le ${today.day}/${today.month}: ${todayRecord.steps}');
      } else {
        // Aucun enregistrement pour aujourd'hui, mais on peut avoir des pas du capteur
        debugPrint('ℹ️ Aucun enregistrement Firestore pour aujourd\'hui ${today.day}/${today.month}');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des pas: $e');
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

