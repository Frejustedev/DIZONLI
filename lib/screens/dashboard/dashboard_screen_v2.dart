import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/step_provider.dart';
import '../../services/step_service.dart';
import '../../services/user_service.dart';
import '../../models/step_record_model.dart';
import '../../models/user_model.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/weekly_chart.dart';
import '../../widgets/stats_summary.dart';
import '../../widgets/mini_leaderboard.dart';
import '../../widgets/stat_card.dart';

class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({Key? key}) : super(key: key);

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  final StepService _stepService = StepService();
  final UserService _userService = UserService();

  List<StepRecordModel> _weekData = [];
  List<UserModel> _topFriends = [];
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Charge les pas de la semaine
      final weekData = await _stepService.getWeekSteps(currentUser.uid);

      // Charge le streak
      final user = await _userService.getUser(currentUser.uid);
      final streak = await _stepService.getStreak(
        currentUser.uid,
        user?.dailyGoal ?? 10000,
      );

      // Charge les top amis
      final friends = await _userService.getFriends(currentUser.uid);
      friends.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

      setState(() {
        _weekData = weekData;
        _streak = streak;
        _topFriends = friends.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
      setState(() => _isLoading = false);
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${user.name.split(' ').first} 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getGreetingMessage(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            stepProvider.initialize(userId: user.id),
            stepProvider.forceSave(),
            _loadData(),
          ]);
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Ring
                    Center(
                      child: ProgressRing(
                        current: stepProvider.steps,
                        goal: user.dailyGoal,
                        size: 220,
                        strokeWidth: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.straighten,
                            title: 'Distance',
                            value: '${stepProvider.distance.toStringAsFixed(2)} km',
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.local_fire_department,
                            title: 'Calories',
                            value: '${stepProvider.calories.toInt()} kcal',
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weekly Chart
                    WeeklyChart(
                      weekData: _weekData,
                      dailyGoal: user.dailyGoal,
                    ),
                    const SizedBox(height: 16),

                    // Stats Summary
                    StatsSummary(
                      totalSteps: user.totalSteps,
                      totalDistance: user.totalDistance.toDouble(),
                      totalCalories: user.totalCalories.toDouble(),
                      streak: _streak,
                    ),
                    const SizedBox(height: 16),

                    // Mini Leaderboard
                    MiniLeaderboard(
                      topFriends: _topFriends,
                      currentUserId: user.uid,
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions
                    _buildQuickActions(context),
                    const SizedBox(height: 16),

                    // Motivational Card
                    _buildMotivationalCard(stepProvider.steps, user.dailyGoal),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildQuickActionTile(
            icon: Icons.group,
            title: 'Groupes',
            subtitle: 'Rejoindre ou créer des groupes',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, '/groups'),
          ),
          const Divider(height: 1),
          _buildQuickActionTile(
            icon: Icons.emoji_events,
            title: 'Défis',
            subtitle: 'Participer aux défis',
            color: AppColors.secondary,
            onTap: () => Navigator.pushNamed(context, '/challenges'),
          ),
          const Divider(height: 1),
          _buildQuickActionTile(
            icon: Icons.people,
            title: 'Fil Social',
            subtitle: 'Voir les activités',
            color: AppColors.accent,
            onTap: () => Navigator.pushNamed(context, '/social'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildMotivationalCard(int steps, int goal) {
    final progress = steps / goal;
    String emoji, title, message;
    Color startColor, endColor;

    if (progress >= 1.0) {
      emoji = '🎉';
      title = 'Objectif Atteint!';
      message = 'Bravo! Vous avez atteint votre objectif quotidien!';
      startColor = AppColors.success;
      endColor = const Color(0xFF66BB6A);
    } else if (progress >= 0.75) {
      emoji = '💪';
      title = 'Presque là!';
      message = 'Plus que ${goal - steps} pas pour atteindre votre objectif!';
      startColor = AppColors.primary;
      endColor = AppColors.primaryDark;
    } else if (progress >= 0.5) {
      emoji = '🚶';
      title = 'À mi-chemin!';
      message = 'Continuez comme ça, vous êtes sur la bonne voie!';
      startColor = AppColors.secondary;
      endColor = AppColors.secondaryDark;
    } else if (progress >= 0.25) {
      emoji = '👍';
      title = 'Bon début!';
      message = 'Chaque pas compte. Continuez à avancer!';
      startColor = AppColors.accent;
      endColor = const Color(0xFFFFA726);
    } else {
      emoji = '🌟';
      title = 'Commençons!';
      message = 'Une marche de mille kilomètres commence par un pas!';
      startColor = AppColors.secondary;
      endColor = AppColors.secondaryLight;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Groupes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Défis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
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
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonne matinée!';
    } else if (hour < 18) {
      return 'Bon après-midi!';
    } else {
      return 'Bonne soirée!';
    }
  }
}

