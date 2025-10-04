import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/badge_model.dart';

/// Widget pour afficher les détails complets d'un badge
class BadgeDetailCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isUnlocked;

  const BadgeDetailCard({
    Key? key,
    required this.badge,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    _getRarityColor().withOpacity(0.1),
                    _getRarityColor().withOpacity(0.05),
                  ]
                : [
                    AppColors.divider.withOpacity(0.1),
                    AppColors.divider.withOpacity(0.05),
                  ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            // Badge Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getRarityColor().withOpacity(0.2)
                    : AppColors.divider.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? _getRarityColor() : AppColors.divider,
                  width: 3,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: _getRarityColor().withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  badge.iconUrl,
                  style: TextStyle(
                    fontSize: 60,
                    color: isUnlocked ? null : Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Badge Name
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Rarity Chip
            _buildRarityChip(),

            const SizedBox(height: 16),

            // Description
            Text(
              isUnlocked ? badge.description : '🔒 Badge verrouillé',
              style: TextStyle(
                fontSize: 16,
                color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: Icons.stars,
                  label: 'Points',
                  value: '${badge.points}',
                  color: AppColors.accent,
                ),
                _buildStatItem(
                  icon: _getCategoryIcon(),
                  label: 'Catégorie',
                  value: _getCategoryLabel(),
                  color: AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Badge débloqué !',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.lock,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Badge verrouillé',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildRarityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _getRarityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRarityColor(),
          width: 2,
        ),
      ),
      child: Text(
        _getRarityLabel(),
        style: TextStyle(
          fontSize: 14,
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

