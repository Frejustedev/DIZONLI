import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/badge_model.dart';

/// Widget pour afficher un badge individuel en liste
class BadgeTile extends StatelessWidget {
  final BadgeModel badge;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const BadgeTile({
    Key? key,
    required this.badge,
    required this.isUnlocked,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnlocked ? _getRarityColor() : AppColors.divider,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Badge Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getRarityColor().withOpacity(0.1)
                      : AppColors.divider.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    badge.iconUrl,
                    style: TextStyle(
                      fontSize: 32,
                      color: isUnlocked ? null : Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Badge Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRarityChip(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? badge.description : '🔒 Badge verrouillé',
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: isUnlocked
                              ? AppColors.accent
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${badge.points} points',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? AppColors.accent
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          _getCategoryIcon(),
                          size: 16,
                          color: isUnlocked
                              ? AppColors.secondary
                              : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnlocked
                                ? AppColors.textSecondary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unlock indicator
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.lock,
                    color: AppColors.textHint,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRarityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRarityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getRarityLabel(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getRarityColor(),
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }

  String _getRarityLabel() {
    switch (badge.rarity) {
      case BadgeRarity.common:
        return 'Commun';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Épique';
      case BadgeRarity.legendary:
        return 'Légendaire';
    }
  }

  IconData _getCategoryIcon() {
    switch (badge.category) {
      case BadgeCategory.achievement:
        return Icons.emoji_events;
      case BadgeCategory.milestone:
        return Icons.flag;
      case BadgeCategory.social:
        return Icons.people;
    }
  }

  String _getCategoryLabel() {
    switch (badge.category) {
      case BadgeCategory.achievement:
        return 'Exploit';
      case BadgeCategory.milestone:
        return 'Étape';
      case BadgeCategory.social:
        return 'Social';
    }
  }
}

