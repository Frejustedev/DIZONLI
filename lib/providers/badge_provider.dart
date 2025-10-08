import 'package:flutter/foundation.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';

/// Provider pour gérer l'état des badges
class BadgeProvider with ChangeNotifier {
  final BadgeService _badgeService = BadgeService();
  
  List<BadgeModel> _allBadges = [];
  List<BadgeModel> _userBadges = [];
  List<BadgeModel> _newlyUnlockedBadges = [];
  bool _isLoading = false;
  String? _error;
  bool _userBadgesLoaded = false; // Pour éviter la boucle infinie

  // Getters
  List<BadgeModel> get allBadges => _allBadges;
  List<BadgeModel> get userBadges => _userBadges;
  List<BadgeModel> get newlyUnlockedBadges => _newlyUnlockedBadges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get userBadgesLoaded => _userBadgesLoaded;
  
  /// Nombre total de badges disponibles
  int get totalBadges => _allBadges.length;
  
  /// Nombre de badges débloqués par l'utilisateur
  int get unlockedBadgesCount => _userBadges.length;
  
  /// Pourcentage de badges débloqués
  double get badgeCompletionPercentage {
    if (_allBadges.isEmpty) return 0.0;
    return (_userBadges.length / _allBadges.length) * 100;
  }
  
  /// Vérifie si un badge est débloqué
  bool isBadgeUnlocked(String badgeId) {
    return _userBadges.any((badge) => badge.id == badgeId);
  }
  
  /// Récupère les badges par catégorie
  List<BadgeModel> getBadgesByCategory(BadgeCategory category) {
    return _allBadges.where((badge) => badge.category == category).toList();
  }
  
  /// Récupère les badges par rareté
  List<BadgeModel> getBadgesByRarity(BadgeRarity rarity) {
    return _allBadges.where((badge) => badge.rarity == rarity).toList();
  }
  
  /// Récupère les badges verrouillés
  List<BadgeModel> get lockedBadges {
    return _allBadges.where((badge) => !isBadgeUnlocked(badge.id)).toList();
  }

  /// Charge tous les badges disponibles
  Future<void> loadAllBadges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🏅 Chargement des badges...');
      // Charger les badges une seule fois au lieu d'utiliser un stream
      final badges = await _badgeService.getAllBadges();
      debugPrint('🏅 Badges récupérés: ${badges.length}');
      
      // Si aucun badge n'existe, initialiser les badges par défaut
      if (badges.isEmpty) {
        debugPrint('⚠️ Aucun badge trouvé, initialisation...');
        await _badgeService.initializeBadges();
        final initializedBadges = await _badgeService.getAllBadges();
        _allBadges = initializedBadges;
        debugPrint('✅ Badges initialisés: ${_allBadges.length}');
      } else {
        _allBadges = badges;
        debugPrint('✅ Badges chargés: ${_allBadges.length}');
      }
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur chargement badges: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les badges d'un utilisateur
  Future<void> loadUserBadges(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🏅 Chargement des badges utilisateur ($userId)...');
      // Charger les badges de l'utilisateur une seule fois
      final badges = await _badgeService.getUserBadges(userId);
      _userBadges = badges;
      _userBadgesLoaded = true; // Marquer comme chargé
      debugPrint('✅ Badges utilisateur chargés: ${_userBadges.length}');
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur chargement badges utilisateur: $e');
      _error = e.toString();
      _isLoading = false;
      _userBadgesLoaded = true; // Marquer comme chargé même en cas d'erreur
      notifyListeners();
    }
  }

  /// Vérifie et débloque automatiquement les badges
  Future<void> checkAndUnlockBadges(String userId) async {
    try {
      debugPrint('🔍 Vérification des badges à débloquer pour $userId...');
      final newBadges = await _badgeService.checkAndUnlockBadges(userId);
      debugPrint('✅ Nouveaux badges débloqués: ${newBadges.length}');
      for (final badge in newBadges) {
        debugPrint('   🏆 ${badge.name} - ${badge.description}');
      }
      
      if (newBadges.isNotEmpty) {
        _newlyUnlockedBadges = newBadges;
        notifyListeners();
        
        // Recharge les badges de l'utilisateur
        await loadUserBadges(userId);
      }
    } catch (e) {
      debugPrint('❌ Erreur vérification badges: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Efface les badges nouvellement débloqués
  void clearNewlyUnlockedBadges() {
    _newlyUnlockedBadges = [];
    notifyListeners();
  }

  /// Initialise les badges dans Firestore (une seule fois)
  Future<void> initializeBadges() async {
    try {
      await _badgeService.initializeBadges();
      await loadAllBadges();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Calcule les statistiques des badges
  Map<String, dynamic> getBadgeStats() {
    final byCategory = <String, int>{};
    final byRarity = <String, int>{};

    // Statistiques par catégorie
    for (final category in BadgeCategory.values) {
      final count = _userBadges.where((b) => b.category == category).length;
      byCategory[category.toString().split('.').last] = count;
    }

    // Statistiques par rareté
    for (final rarity in BadgeRarity.values) {
      final count = _userBadges.where((b) => b.rarity == rarity).length;
      byRarity[rarity.toString().split('.').last] = count;
    }

    final stats = {
      'total': _allBadges.length,
      'unlocked': _userBadges.length,
      'locked': _allBadges.length - _userBadges.length,
      'percentage': badgeCompletionPercentage,
      'byCategory': byCategory,
      'byRarity': byRarity,
    };

    return stats;
  }
}

