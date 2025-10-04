import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../providers/badge_provider.dart';
import '../../models/badge_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: user.photoUrl != null
                        ? ClipOval(child: Image.network(user.photoUrl!, fit: BoxFit.cover))
                        : const Icon(Icons.person, size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getLevelColor(user.userLevel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getLevelIcon(user.userLevel), color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          user.userLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatCard(
                    'Total de pas',
                    user.totalSteps.toString(),
                    Icons.directions_walk,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Distance',
                          '${(user.totalDistance / 1000).toStringAsFixed(1)} km',
                          Icons.straighten,
                          AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Calories',
                          '${user.totalCalories} kcal',
                          Icons.local_fire_department,
                          AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBadgesSection(context, user.id),
                  const SizedBox(height: 16),
                  _buildMenuSection(context, user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context, String userId) {
    return Consumer<BadgeProvider>(
      builder: (context, badgeProvider, child) {
        // Load user badges if not already loaded
        if (badgeProvider.userBadges.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            badgeProvider.loadUserBadges(userId);
          });
        }

        final recentBadges = badgeProvider.userBadges.take(3).toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: AppColors.accent),
                        const SizedBox(width: 8),
                        const Text(
                          'Badges',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${badgeProvider.unlockedBadgesCount}/${badgeProvider.totalBadges}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/badges'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentBadges.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Aucun badge débloqué pour le moment',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentBadges.length,
                      itemBuilder: (context, index) {
                        final badge = recentBadges[index];
                        return _buildBadgeItem(badge);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeItem(BadgeModel badge) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getBadgeRarityColor(badge.rarity).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBadgeRarityColor(badge.rarity),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                badge.iconUrl,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getBadgeRarityColor(BadgeRarity rarity) {
    switch (rarity) {
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.flag, color: AppColors.primary),
            title: const Text('Objectif journalier'),
            subtitle: Text('${user.dailyGoal} pas'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Edit goal
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: AppColors.accent),
            title: const Text(AppStrings.badges),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/badges');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: AppColors.gold),
            title: const Text(AppStrings.certificates),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: View certificates
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.textSecondary),
            title: const Text(AppStrings.settings),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(AppStrings.logout),
            onTap: () async {
              await context.read<UserProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'champion':
        return AppColors.champion;
      case 'gold':
        return AppColors.gold;
      case 'silver':
        return AppColors.silver;
      case 'bronze':
      default:
        return AppColors.bronze;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'champion':
        return Icons.workspace_premium;
      case 'gold':
      case 'silver':
      case 'bronze':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }
}

