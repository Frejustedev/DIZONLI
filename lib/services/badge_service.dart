import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge_model.dart';
import 'firestore_service.dart';
import 'user_service.dart';

/// Service de gestion des badges et gamification
class BadgeService {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  static const String _collection = 'badges';

  /// Récupère tous les badges disponibles
  Stream<List<BadgeModel>> streamAllBadges() {
    return _firestoreService.streamCollection(_collection).map((snapshot) {
      return snapshot.docs
          .map((doc) => BadgeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  /// Récupère un badge spécifique
  Future<BadgeModel?> getBadge(String badgeId) async {
    try {
      final doc = await _firestoreService.getDocument(_collection, badgeId);
      if (doc.exists) {
        return BadgeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du badge: $e');
    }
  }

  /// Récupère les badges d'un utilisateur
  Stream<List<BadgeModel>> streamUserBadges(String userId) {
    return _userService.streamUser(userId).asyncMap((user) async {
      if (user == null || user.badges.isEmpty) return <BadgeModel>[];
      
      // Récupère tous les badges de l'utilisateur
      final badges = <BadgeModel>[];
      for (final badgeId in user.badges) {
        final badge = await getBadge(badgeId);
        if (badge != null) badges.add(badge);
      }
      return badges;
    });
  }

  /// Vérifie et débloque automatiquement les badges pour un utilisateur
  Future<List<BadgeModel>> checkAndUnlockBadges(String userId) async {
    try {
      // Récupère l'utilisateur
      final userSnapshot = await _firestoreService.getDocument('users', userId);
      if (!userSnapshot.exists) return [];
      
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final userBadges = List<String>.from(userData['badges'] ?? []);
      
      // Récupère tous les badges disponibles
      final allBadgesSnapshot = await _firestoreService.getCollection(_collection);
      final allBadges = allBadgesSnapshot.docs
          .map((doc) => BadgeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      final newlyUnlockedBadges = <BadgeModel>[];
      
      for (final badge in allBadges) {
        // Vérifie si l'utilisateur a déjà ce badge
        if (userBadges.contains(badge.id)) continue;
        
        // Vérifie si l'utilisateur remplit les conditions
        if (_checkBadgeCondition(badge, userData)) {
          await _userService.awardBadge(userId, badge.id);
          newlyUnlockedBadges.add(badge);
        }
      }
      
      return newlyUnlockedBadges;
    } catch (e) {
      throw Exception('Erreur lors de la vérification des badges: $e');
    }
  }

  /// Vérifie si un utilisateur remplit la condition d'un badge
  bool _checkBadgeCondition(BadgeModel badge, Map<String, dynamic> userData) {
    final totalSteps = userData['totalSteps'] ?? 0;
    final level = userData['level'] ?? 1;
    final friendsCount = (userData['friends'] as List?)?.length ?? 0;
    
    switch (badge.condition) {
      case 'first_steps':
        return totalSteps >= 1;
      
      case 'steps_1000':
        return totalSteps >= 1000;
      
      case 'steps_10000':
        return totalSteps >= 10000;
      
      case 'steps_50000':
        return totalSteps >= 50000;
      
      case 'steps_100000':
        return totalSteps >= 100000;
      
      case 'steps_500000':
        return totalSteps >= 500000;
      
      case 'steps_1000000':
        return totalSteps >= 1000000;
      
      case 'level_5':
        return level >= 5;
      
      case 'level_10':
        return level >= 10;
      
      case 'level_25':
        return level >= 25;
      
      case 'level_50':
        return level >= 50;
      
      case 'friends_1':
        return friendsCount >= 1;
      
      case 'friends_5':
        return friendsCount >= 5;
      
      case 'friends_10':
        return friendsCount >= 10;
      
      case 'friends_25':
        return friendsCount >= 25;
      
      default:
        return false;
    }
  }

  /// Crée les badges initiaux dans Firestore (à appeler une seule fois)
  Future<void> initializeBadges() async {
    try {
      final badges = _getInitialBadges();
      
      for (final badge in badges) {
        await _firestoreService.setDocument(_collection, badge.id, badge.toMap());
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'initialisation des badges: $e');
    }
  }

  /// Retourne la liste des badges initiaux
  List<BadgeModel> _getInitialBadges() {
    return [
      // Badges de pas
      BadgeModel(
        id: 'first_steps',
        name: 'Premier Pas',
        description: 'Faites votre premier pas dans l\'aventure !',
        iconUrl: '🚶',
        condition: 'first_steps',
        rarity: BadgeRarity.common,
        points: 10,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'steps_1000',
        name: 'Marcheur Débutant',
        description: 'Atteignez 1 000 pas au total',
        iconUrl: '👟',
        condition: 'steps_1000',
        rarity: BadgeRarity.common,
        points: 25,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'steps_10000',
        name: 'Marcheur Confirmé',
        description: 'Atteignez 10 000 pas au total',
        iconUrl: '🏃',
        condition: 'steps_10000',
        rarity: BadgeRarity.rare,
        points: 50,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'steps_50000',
        name: 'Coureur Amateur',
        description: 'Atteignez 50 000 pas au total',
        iconUrl: '🏃‍♂️',
        condition: 'steps_50000',
        rarity: BadgeRarity.rare,
        points: 100,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'steps_100000',
        name: 'Athlète',
        description: 'Atteignez 100 000 pas au total',
        iconUrl: '🏅',
        condition: 'steps_100000',
        rarity: BadgeRarity.epic,
        points: 200,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'steps_500000',
        name: 'Champion',
        description: 'Atteignez 500 000 pas au total',
        iconUrl: '🥇',
        condition: 'steps_500000',
        rarity: BadgeRarity.epic,
        points: 500,
        category: BadgeCategory.achievement,
      ),
      BadgeModel(
        id: 'steps_1000000',
        name: 'Légende',
        description: 'Atteignez 1 000 000 pas au total',
        iconUrl: '👑',
        condition: 'steps_1000000',
        rarity: BadgeRarity.legendary,
        points: 1000,
        category: BadgeCategory.achievement,
      ),
      
      // Badges de niveau
      BadgeModel(
        id: 'level_5',
        name: 'Novice',
        description: 'Atteignez le niveau 5',
        iconUrl: '⭐',
        condition: 'level_5',
        rarity: BadgeRarity.common,
        points: 30,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'level_10',
        name: 'Expert',
        description: 'Atteignez le niveau 10',
        iconUrl: '🌟',
        condition: 'level_10',
        rarity: BadgeRarity.rare,
        points: 75,
        category: BadgeCategory.milestone,
      ),
      BadgeModel(
        id: 'level_25',
        name: 'Maître',
        description: 'Atteignez le niveau 25',
        iconUrl: '💫',
        condition: 'level_25',
        rarity: BadgeRarity.epic,
        points: 200,
        category: BadgeCategory.achievement,
      ),
      BadgeModel(
        id: 'level_50',
        name: 'Grand Maître',
        description: 'Atteignez le niveau 50',
        iconUrl: '✨',
        condition: 'level_50',
        rarity: BadgeRarity.legendary,
        points: 500,
        category: BadgeCategory.achievement,
      ),
      
      // Badges sociaux
      BadgeModel(
        id: 'friends_1',
        name: 'Premier Ami',
        description: 'Ajoutez votre premier ami',
        iconUrl: '👋',
        condition: 'friends_1',
        rarity: BadgeRarity.common,
        points: 20,
        category: BadgeCategory.social,
      ),
      BadgeModel(
        id: 'friends_5',
        name: 'Sociable',
        description: 'Ajoutez 5 amis',
        iconUrl: '👥',
        condition: 'friends_5',
        rarity: BadgeRarity.rare,
        points: 50,
        category: BadgeCategory.social,
      ),
      BadgeModel(
        id: 'friends_10',
        name: 'Populaire',
        description: 'Ajoutez 10 amis',
        iconUrl: '👫',
        condition: 'friends_10',
        rarity: BadgeRarity.epic,
        points: 100,
        category: BadgeCategory.social,
      ),
      BadgeModel(
        id: 'friends_25',
        name: 'Influenceur',
        description: 'Ajoutez 25 amis',
        iconUrl: '🌟',
        condition: 'friends_25',
        rarity: BadgeRarity.legendary,
        points: 250,
        category: BadgeCategory.social,
      ),
    ];
  }
}

