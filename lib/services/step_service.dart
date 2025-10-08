import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/step_record_model.dart';
import 'firestore_service.dart';
import 'user_service.dart';

/// Service de gestion des pas quotidiens
class StepService {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'steps';

  /// Crée ou met à jour l'enregistrement des pas du jour
  Future<void> saveSteps(String userId, int steps, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${userId}_$dateStr';

      // Calculs
      final distanceKm = steps * 0.000762; // km (0.762m par pas)
      final distanceMeters = steps * 0.762; // mètres (0.762m par pas)
      final calories = steps * 0.04; // 0.04 calories par pas

      final data = {
        'userId': userId,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'steps': steps,
        'distance': distanceKm, // Stocké en km dans les records
        'calories': calories,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Vérifie si le document existe
      final existing = await _firestoreService.readDocument(_collection, docId);

      if (existing == null) {
        // Création
        data['goalAchieved'] = false;
        data['hourlyData'] = [];
        await _firestoreService.createDocument(_collection, docId, data);
      } else {
        // Mise à jour
        await _firestoreService.updateDocument(_collection, docId, data);
      }

      // Met à jour les stats totales de l'utilisateur
      if (existing == null || existing['steps'] < steps) {
        final existingSteps = existing?['steps'];
        final existingDistanceKm = existing?['distance'];
        final existingCalories = existing?['calories'];
        
        final incrementSteps = existing == null ? steps : steps - ((existingSteps is int) ? existingSteps : (existingSteps as num).toInt());
        
        // Calculer l'incrément en mètres pour totalDistance
        final existingDistanceMeters = existingDistanceKm == null ? 0.0 : ((existingDistanceKm is double) ? existingDistanceKm : (existingDistanceKm as num).toDouble()) * 1000;
        final incrementDistanceMeters = existing == null ? distanceMeters : distanceMeters - existingDistanceMeters;
        
        final incrementCalories = existing == null ? calories : calories - ((existingCalories is double) ? existingCalories : (existingCalories as num).toDouble());
        
        await _userService.updateTotalStats(
          userId,
          steps: incrementSteps,
          distanceMeters: incrementDistanceMeters.toInt(),
          calories: incrementCalories,
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des pas: $e');
    }
  }

  /// Marque l'objectif comme atteint
  Future<void> markGoalAchieved(String userId, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${userId}_$dateStr';

      await _firestoreService.updateDocument(_collection, docId, {
        'goalAchieved': true,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'objectif: $e');
    }
  }

  /// Récupère les pas d'un jour spécifique
  Future<StepRecordModel?> getStepsByDate(String userId, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${userId}_$dateStr';

      final data = await _firestoreService.readDocument(_collection, docId);
      return data != null ? StepRecordModel.fromJson(data) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pas: $e');
    }
  }

  /// Récupère les pas des N derniers jours
  Future<List<StepRecordModel>> getStepsHistory(String userId, int days) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StepRecordModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique: $e');
    }
  }

  /// Récupère tous les enregistrements de pas d'un utilisateur
  Future<List<StepRecordModel>> getAllStepRecords(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => StepRecordModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de tous les enregistrements: $e');
    }
  }

  /// Récupère les pas de la semaine en cours (7 jours complets)
  Future<List<StepRecordModel>> getWeekSteps(String userId) async {
    return getStepsHistory(userId, 7); // ✅ Toujours 7 jours pour la semaine complète
  }

  /// Récupère les pas du mois en cours
  Future<List<StepRecordModel>> getMonthSteps(String userId) async {
    final now = DateTime.now();
    return getStepsHistory(userId, now.day);
  }

  /// Calcule le total des pas pour une période
  Future<int> getTotalSteps(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        final steps = doc.data()['steps'];
        total += (steps is int) ? steps : (steps as num).toInt();
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul du total: $e');
    }
  }

  /// Calcule la moyenne quotidienne
  Future<double> getAverageDailySteps(String userId, int days) async {
    try {
      final records = await getStepsHistory(userId, days);
      if (records.isEmpty) return 0;

      final total = records.fold<int>(0, (sum, record) => sum + record.steps);
      return total / records.length;
    } catch (e) {
      throw Exception('Erreur lors du calcul de la moyenne: $e');
    }
  }

  /// Vérifie si l'objectif est atteint aujourd'hui
  Future<bool> isGoalAchievedToday(String userId, int dailyGoal) async {
    try {
      final today = await getStepsByDate(userId, DateTime.now());
      return today != null && today.steps >= dailyGoal;
    } catch (e) {
      return false;
    }
  }

  /// Recalcule les statistiques totales depuis zéro (correction des données corrompues)
  Future<void> recalculateTotalStats(String userId) async {
    try {
      debugPrint('🔄 Recalcul complet des statistiques totales...');
      
      // Récupère TOUS les enregistrements
      final allRecords = await getAllStepRecords(userId);
      
      if (allRecords.isEmpty) {
        debugPrint('⚠️ Aucun enregistrement trouvé pour le recalcul');
        return;
      }
      
      // Calcule les totaux réels
      int totalSteps = 0;
      double totalDistanceKm = 0;
      double totalCalories = 0;
      
      for (final record in allRecords) {
        totalSteps += record.steps;
        totalDistanceKm += record.distance; // déjà en km dans les records
        totalCalories += record.calories.toDouble();
      }
      
      // Convertit la distance en mètres pour totalDistance dans user
      final totalDistanceMeters = (totalDistanceKm * 1000).toInt();
      
      debugPrint('✅ Statistiques recalculées:');
      debugPrint('   - Pas: $totalSteps');
      debugPrint('   - Distance: ${totalDistanceMeters}m (${totalDistanceKm.toStringAsFixed(2)}km)');
      debugPrint('   - Calories: ${totalCalories.toInt()}');
      debugPrint('   - Nombre d\'enregistrements: ${allRecords.length}');
      
      // Met à jour directement (pas d'incrément) les stats dans Firestore
      await _firestore.collection('users').doc(userId).update({
        'totalSteps': totalSteps,
        'totalDistance': totalDistanceMeters,
        'totalCalories': totalCalories.toInt(),
      });
      
      debugPrint('✅ Statistiques totales mises à jour avec succès!');
    } catch (e) {
      debugPrint('❌ Erreur lors du recalcul: $e');
      throw Exception('Erreur lors du recalcul des statistiques: $e');
    }
  }

  /// Compte le nombre de jours d'affilée avec objectif atteint (streak)
  Future<int> getStreak(String userId, int dailyGoal) async {
    try {
      int streak = 0;
      DateTime currentDate = DateTime.now();

      while (true) {
        final record = await getStepsByDate(userId, currentDate);
        if (record == null || record.steps < dailyGoal) break;

        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));

        // Limite pour éviter les boucles infinies
        if (streak > 365) break;
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  /// Stream pour écouter les changements des pas du jour
  Stream<StepRecordModel?> watchTodaySteps(String userId) {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docId = '${userId}_$dateStr';

    return _firestoreService
        .watchDocument(_collection, docId)
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return StepRecordModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Enregistre les données horaires (optionnel)
  Future<void> saveHourlyData(String userId, DateTime date, int hour, int steps) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final docId = '${userId}_$dateStr';

      await _firestore.collection(_collection).doc(docId).update({
        'hourlyData': FieldValue.arrayUnion([
          {'hour': hour, 'steps': steps}
        ]),
      });
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des données horaires: $e');
    }
  }
}

