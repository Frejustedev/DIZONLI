import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/user_provider.dart';
import '../../providers/step_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/step_circle.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge_unlock_dialog.dart';
import '../social/friends_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        await context.read<StepProvider>().initialize(
          userId: userProvider.currentUser!.id,
        );
      }
      await _checkBadges();
    });
  }

  Future<void> _checkBadges() async {
    final userProvider = context.read<UserProvider>();
    final badgeProvider = context.read<BadgeProvider>();
    
    if (userProvider.currentUser != null) {
      // Check and unlock badges
      await badgeProvider.checkAndUnlockBadges(userProvider.currentUser!.id);
      
      // Load unread notifications
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.loadUnreadNotifications(userProvider.currentUser!.id);
      
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = stepProvider.getProgress(user.dailyGoal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${user.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await stepProvider.initialize(userId: user.id);
          await stepProvider.forceSave();
          await _checkBadges();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Counter Circle
              StepCircle(
                steps: stepProvider.steps,
                goal: user.dailyGoal,
                progress: progress,
              ),
              const SizedBox(height: 24),
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.straighten,
                      title: AppStrings.distance,
                      value: '${stepProvider.distance.toStringAsFixed(2)} km',
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department,
                      title: AppStrings.calories,
                      value: '${stepProvider.calories} kcal',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.group, color: AppColors.primary),
                      ),
                      title: const Text(AppStrings.groups),
                      subtitle: const Text('Rejoindre ou créer des groupes'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/groups');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_events, color: AppColors.secondary),
                      ),
                      title: const Text(AppStrings.challenges),
                      subtitle: const Text('Participer aux défis'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/challenges');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.people, color: AppColors.accent),
                      ),
                      title: const Text(AppStrings.community_feed),
                      subtitle: const Text('Voir les activités'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/social');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_add, color: AppColors.primary),
                      ),
                      title: const Text('Amis'),
                      subtitle: const Text('Gérer vos amis'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FriendsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Motivation Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💪 Conseil du jour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMotivationalMessage(stepProvider.steps, user.dailyGoal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groupes'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Défis'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/groups');
              break;
            case 2:
              Navigator.pushNamed(context, '/challenges');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  String _getMotivationalMessage(int steps, int goal) {
    final progress = steps / goal;
    if (progress >= 1.0) {
      return 'Bravo! Vous avez atteint votre objectif! 🎉';
    } else if (progress >= 0.75) {
      return 'Presque là! Plus que ${goal - steps} pas!';
    } else if (progress >= 0.5) {
      return 'Vous êtes à mi-chemin! Continuez! 💪';
    } else if (progress >= 0.25) {
      return 'Bon début! Continuez à marcher!';
    } else {
      return 'Commencez votre journée active! Chaque pas compte!';
    }
  }
}

