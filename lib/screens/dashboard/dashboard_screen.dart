import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/step_provider.dart';
import '../../services/step_service.dart';
import '../../services/friendship_service.dart';
import '../../models/step_record_model.dart';
import '../../models/user_model.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/simple_weekly_histograms.dart';
import '../../widgets/stats_summary.dart';
import '../../widgets/mini_leaderboard.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StepService _stepService = StepService();
  final FriendshipService _friendshipService = FriendshipService();

  List<StepRecordModel> _weekData = [];
  List<UserModel> _topFriends = [];
  String _walkingTime = '0 min';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        // Initialiser le StepProvider
        await context.read<StepProvider>().initialize(
          userId: userProvider.currentUser!.id,
        );
      }
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ Aucun utilisateur connecté');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      debugPrint('🔄 Chargement des données du dashboard...');

      // 🔧 RECALCUL des statistiques totales (correction des données corrompues)
      try {
        await _stepService.recalculateTotalStats(currentUser.uid);
        // Force le rechargement du UserProvider pour afficher les nouvelles stats
        if (mounted) {
          await context.read<UserProvider>().loadUser(currentUser.uid);
        }
      } catch (e) {
        debugPrint('⚠️ Erreur lors du recalcul des stats: $e');
      }

      // Charge les pas de la semaine
      List<StepRecordModel> weekData = [];
      try {
        weekData = await _stepService.getWeekSteps(currentUser.uid);
        debugPrint('✅ Données de la semaine chargées: ${weekData.length} jours');
      } catch (e) {
        debugPrint('⚠️ Erreur chargement semaine: $e');
      }

      // Calcule le temps de marche basé sur les pas du jour
      String walkingTime = '0 min';
      try {
        final todayRecord = await _stepService.getStepsByDate(
          currentUser.uid,
          DateTime.now(),
        );
        final todaySteps = todayRecord?.steps ?? 0;
        walkingTime = _calculateWalkingTime(todaySteps);
        debugPrint('✅ Temps de marche calculé: $walkingTime pour $todaySteps pas');
      } catch (e) {
        debugPrint('⚠️ Erreur calcul temps: $e');
      }

      // Charge les top amis
      List<UserModel> friends = [];
      try {
        friends = await _friendshipService.getFriendsProfiles(currentUser.uid);
        friends.sort((a, b) => b.totalSteps.compareTo(a.totalSteps));
        debugPrint('✅ Amis chargés: ${friends.length} amis trouvés');
      } catch (e) {
        debugPrint('⚠️ Erreur chargement amis: $e');
      }

      if (mounted) {
        setState(() {
          _weekData = weekData;
          _walkingTime = walkingTime;
          _topFriends = friends.take(3).toList();
          _isLoading = false;
        });
        debugPrint('✅ Dashboard mis à jour avec succès');
      }
    } catch (e) {
      debugPrint('❌ Erreur globale lors du chargement: $e');
      if (mounted) setState(() => _isLoading = false);
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

    return RefreshIndicator(
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

                  // Histogrammes Semaine (Pas et Distance)
                  SimpleWeeklyHistograms(
                    weekData: _weekData,
                    dailyGoal: user.dailyGoal,
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.local_fire_department,
                          title: 'Calories',
                          value: '${stepProvider.calories.toInt()} kcal',
                          color: AppColors.accent,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.access_time,
                        title: 'Temps',
                        value: _walkingTime,
                        color: AppColors.primary,
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Summary
                  StatsSummary(
                    totalSteps: user.totalSteps,
                    totalDistance: user.totalDistance / 1000, // Convertir mètres en km
                    totalCalories: user.totalCalories.toDouble(),
                    streak: 0, // On garde pour compatibilité mais n'est plus affiché
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

  /// Calcule le temps de marche basé sur le nombre de pas
  /// Distance = pas × 0.762 m (longueur moyenne d'un pas)
  /// Vitesse moyenne = 5 km/h
  /// Temps = Distance / Vitesse
  String _calculateWalkingTime(int steps) {
    if (steps == 0) return '0 min';

    // Calcul de la distance en km
    final distanceKm = steps * 0.000762; // 0.762 m par pas = 0.000762 km

    // Vitesse moyenne de marche : 5 km/h
    const averageSpeedKmh = 5.0;

    // Temps en heures
    final timeHours = distanceKm / averageSpeedKmh;

    // Convertir en minutes
    final timeMinutes = (timeHours * 60).round();

    if (timeMinutes < 60) {
      return '$timeMinutes min';
    } else {
      final hours = timeMinutes ~/ 60;
      final minutes = timeMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${minutes}min';
    }
  }
}

