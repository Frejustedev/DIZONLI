import 'dart:async';
import 'package:flutter/foundation.dart';
import 'health_sync_service.dart';

/// Service de synchronisation en arrière-plan
/// Se déclenche périodiquement pour synchroniser les pas automatiquement
class BackgroundStepSyncService {
  static final BackgroundStepSyncService _instance = BackgroundStepSyncService._internal();
  factory BackgroundStepSyncService() => _instance;
  BackgroundStepSyncService._internal();

  final HealthSyncService _healthSync = HealthSyncService();
  Timer? _periodicSync;
  bool _isRunning = false;
  String? _userId;

  /// Démarrer la synchronisation automatique
  Future<void> startPeriodicSync(String userId) async {
    if (_isRunning) {
      debugPrint('⚠️ Synchronisation déjà en cours');
      return;
    }

    _userId = userId;
    
    // Initialiser le service Health
    final initialized = await _healthSync.initialize(userId);
    if (!initialized) {
      debugPrint('❌ Impossible d\'initialiser Health Sync');
      throw Exception('Health Sync initialization failed');
    }

    _isRunning = true;
    debugPrint('✅ Synchronisation automatique démarrée');

    // Synchroniser immédiatement
    await _healthSync.syncTodaySteps();

    // Démarrer la synchronisation périodique (toutes les 15 minutes)
    _periodicSync = Timer.periodic(
      const Duration(minutes: 15),
      (timer) async {
        if (_userId != null) {
          debugPrint('🔄 Synchronisation automatique...');
          await _healthSync.syncTodaySteps();
        }
      },
    );
  }

  /// Arrêter la synchronisation
  void stopPeriodicSync() {
    _periodicSync?.cancel();
    _periodicSync = null;
    _isRunning = false;
    debugPrint('⏹️ Synchronisation automatique arrêtée');
  }

  /// Forcer une synchronisation immédiate
  Future<void> forceSyncNow() async {
    if (_userId != null) {
      debugPrint('🔄 Synchronisation forcée...');
      await _healthSync.syncTodaySteps();
    }
  }

  /// Synchroniser l'historique (ex: 7 derniers jours)
  Future<void> syncHistory(int days) async {
    if (_userId != null) {
      debugPrint('📅 Synchronisation historique: $days jours...');
      await _healthSync.syncHistoricalData(days);
    }
  }

  /// Obtenir les pas du jour directement du système
  Future<int> getTodaySteps() async {
    return await _healthSync.getTodayStepsFromSystem();
  }

  /// Vérifier si le service est actif
  bool get isRunning => _isRunning;
}
