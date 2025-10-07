import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/step_provider.dart';
import '../../providers/badge_provider.dart';
import '../../widgets/step_circle.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/weekly_chart.dart';
import '../../widgets/badge_unlock_dialog.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        await context.read<StepProvider>().initialize(
          userId: userProvider.currentUser!.id,
        );
      }
      await _checkBadges();
    });
  }
  Future<void> _initializeApp() async {
    final badgeProvider = context.read<BadgeProvider>();
    
    // Initialize badges in Firestore (only once, idempotent)
    try {
      await badgeProvider.initializeBadges();
    } catch (e) {
      debugPrint('Badge initialization error: $e');
    }
  }

  Future<void> _checkBadges() async {
    final userProvider = context.read<UserProvider>();
    final badgeProvider = context.read<BadgeProvider>();
    
    if (userProvider.currentUser != null) {
      // Check and unlock badges
      await badgeProvider.checkAndUnlockBadges(userProvider.currentUser!.id);
      
      // Show dialog for newly unlocked badges
      if (badgeProvider.newlyUnlockedBadges.isNotEmpty && mounted) {
        for (final badge in badgeProvider.newlyUnlockedBadges) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => BadgeUnlockDialog(badge: badge),
          );
        }
        // Clear the newly unlocked badges after showing
        badgeProvider.clearNewlyUnlockedBadges();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final stepProvider = context.watch<StepProvider>();
    final user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progress = stepProvider.getProgress(user.dailyGoal);

    return RefreshIndicator(
      onRefresh: () async {
        await stepProvider.initialize(userId: user.id);
        await stepProvider.forceSave(); // Forcer la sauvegarde lors du refresh
        await stepProvider.refreshFromSystem(); // Rafraîchir depuis le système
        await _checkBadges();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la section
            const Text(
              'Pas d\'aujourd\'hui',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Cercle de progression
            Center(
              child: StepCircle(
                steps: stepProvider.steps,
                goal: user.dailyGoal,
                progress: progress,
              ),
            ),
            const SizedBox(height: 30),
            
            // Statistiques
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.straighten,
                    color: AppColors.accent,
                    title: 'Distance',
                    value: '${stepProvider.distance.toStringAsFixed(2)} km',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    title: 'Calories',
                    value: '${stepProvider.calories.toStringAsFixed(0)} kcal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Message de motivation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    progress >= 1.0
                        ? Icons.celebration
                        : Icons.directions_walk,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getMotivationalMessage(progress),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Graphique hebdomadaire
            const Text(
              'Activité de la semaine',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: WeeklyChart(
                weekData: const [],
                dailyGoal: user.dailyGoal,
              ),
            ),
            const SizedBox(height: 20),
            
            // Actions rapides
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.groups,
                  label: 'Mes Groupes',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pushNamed(context, '/groups');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.emoji_events,
                  label: 'Défis',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pushNamed(context, '/challenges');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.military_tech,
                  label: 'Badges',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(context, '/badges');
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.people,
                  label: 'Social',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/social');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 1.0) {
      return '🎉 Objectif atteint ! Bravo ! Continuez comme ça !';
    } else if (progress >= 0.8) {
      return '💪 Plus que ${((1 - progress) * 100).toInt()}% pour atteindre votre objectif !';
    } else if (progress >= 0.5) {
      return '👏 Vous êtes à mi-chemin ! Continuez vos efforts !';
    } else if (progress >= 0.25) {
      return '🚶 Bon début ! Chaque pas compte !';
    } else {
      return '🌅 Nouvelle journée, nouvelles opportunités ! En route !';
    }
  }
}
