import 'package:cloud_firestore/cloud_firestore.dart';

/// Rareté du badge
enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Catégorie du badge
enum BadgeCategory {
  achievement,
  milestone,
  social,
}

/// Modèle de badge gamification
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String condition;
  final BadgeRarity rarity;
  final int points;
  final BadgeCategory category;
  final DateTime? createdAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.condition,
    required this.rarity,
    required this.points,
    required this.category,
    this.createdAt,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BadgeModel(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      condition: map['condition'] ?? '',
      rarity: _parseRarity(map['rarity']),
      points: map['points'] ?? 0,
      category: _parseCategory(map['category']),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'condition': condition,
      'rarity': rarity.toString().split('.').last,
      'points': points,
      'category': category.toString().split('.').last,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  static BadgeRarity _parseRarity(dynamic rarity) {
    if (rarity == null) return BadgeRarity.common;
    if (rarity is BadgeRarity) return rarity;
    
    final rarityStr = rarity.toString().toLowerCase();
    switch (rarityStr) {
      case 'rare':
        return BadgeRarity.rare;
      case 'epic':
        return BadgeRarity.epic;
      case 'legendary':
        return BadgeRarity.legendary;
      default:
        return BadgeRarity.common;
    }
  }

  static BadgeCategory _parseCategory(dynamic category) {
    if (category == null) return BadgeCategory.milestone;
    if (category is BadgeCategory) return category;
    
    final categoryStr = category.toString().toLowerCase();
    switch (categoryStr) {
      case 'achievement':
        return BadgeCategory.achievement;
      case 'social':
        return BadgeCategory.social;
      default:
        return BadgeCategory.milestone;
    }
  }
}
