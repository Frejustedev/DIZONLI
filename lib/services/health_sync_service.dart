import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'step_service.dart';

/// Service de synchronisation avec Google Fit / Health Connect
/// Permet de lire les pas du système automatiquement 24h/24
class HealthSyncService {
  final Health _health = Health();
  final StepService _stepService = StepService();
  
  bool _isInitialized = false;
  String? _userId;

  /// Types de données à synchroniser
  static final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  /// Permissions nécessaires
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Initialiser le service
  Future<bool> initialize(String userId) async {
    _userId = userId;
    
    try {
      // Vérifier les permissions Android
      if (!kIsWeb) {
        final activityStatus = await Permission.activityRecognition.status;
        if (!activityStatus.isGranted) {
          final result = await Permission.activityRecognition.request();
          if (!result.isGranted) {
            debugPrint('❌ Permission Activity Recognition refusée');
            return false;
          }
        }
      }

      // Demander les permissions Health
      bool authorized = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );

      if (!authorized) {
        debugPrint('❌ Permissions Health refusées');
        return false;
      }

      _isInitialized = true;
      debugPrint('✅ HealthSyncService initialisé avec succès');
      
      // Synchroniser immédiatement
      await syncTodaySteps();
      
      return true;
    } catch (e) {
      debugPrint('❌ Erreur initialisation HealthSyncService: $e');
      return false;
    }
  }

  /// Synchroniser les pas du jour actuel
  Future<void> syncTodaySteps() async {
    if (!_isInitialized || _userId == null) {
      debugPrint('⚠️ Service non initialisé');
      return;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Lire les données de santé
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: startOfDay,
        endTime: endOfDay,
      );

      // Filtrer uniquement les pas
      final stepsData = healthData.where(
        (data) => data.type == HealthDataType.STEPS,
      );

      // Calculer le total de pas
      int totalSteps = 0;
      for (var data in stepsData) {
        if (data.value is NumericHealthValue) {
          final value = (data.value as NumericHealthValue).numericValue;
          totalSteps += value.toInt();
        }
      }

      if (totalSteps > 0) {
        // Sauvegarder dans Firestore
        await _stepService.saveSteps(
          _userId!,
          totalSteps,
          now,
        );
        
        debugPrint('✅ Synchronisation réussie : $totalSteps pas');
      } else {
        debugPrint('⚠️ Aucune donnée de pas trouvée');
      }
    } catch (e) {
      debugPrint('❌ Erreur synchronisation: $e');
    }
  }

  /// Synchroniser l'historique des N derniers jours
  Future<void> syncHistoricalData(int days) async {
    if (!_isInitialized || _userId == null) return;

    try {
      final now = DateTime.now();
      
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        // Lire les données
        List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: startOfDay,
          endTime: endOfDay,
        );

        // Calculer le total
        int totalSteps = 0;
        for (var data in healthData) {
          if (data.value is NumericHealthValue) {
            final value = (data.value as NumericHealthValue).numericValue;
            totalSteps += value.toInt();
          }
        }

        if (totalSteps > 0) {
          await _stepService.saveSteps(
            _userId!,
            totalSteps,
            date,
          );
        }

        // Petit délai pour éviter la surcharge
        await Future.delayed(const Duration(milliseconds: 500));
      }

      debugPrint('✅ Historique synchronisé : $days jours');
    } catch (e) {
      debugPrint('❌ Erreur sync historique: $e');
    }
  }

  /// Vérifier si Health Connect / Google Fit est disponible
  Future<bool> isHealthDataAvailable() async {
    try {
      return await _health.hasPermissions(_types, permissions: _permissions) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir les pas du jour depuis le système
  Future<int> getTodayStepsFromSystem() async {
    if (!_isInitialized) return 0;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      int totalSteps = 0;
      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          final value = (data.value as NumericHealthValue).numericValue;
          totalSteps += value.toInt();
        }
      }

      return totalSteps;
    } catch (e) {
      debugPrint('❌ Erreur lecture pas système: $e');
      return 0;
    }
  }
}
