import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/step_service.dart';
import '../../widgets/group_member_tile.dart';
import '../profile/user_profile_screen.dart';

enum LeaderboardPeriod { today, week, month, year, allTime }

/// Écran affichant le classement complet avec filtres de période
class FullLeaderboardScreen extends StatefulWidget {
  final List<UserModel> members;
  final String currentUserId;
  final String adminId;
  final String groupName;

  const FullLeaderboardScreen({
    super.key,
    required this.members,
    required this.currentUserId,
    required this.adminId,
    required this.groupName,
  });

  @override
  State<FullLeaderboardScreen> createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen> {
  final StepService _stepService = StepService();
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.allTime;
  List<UserModel> _rankedMembers = [];
  Map<String, int> _memberStepsMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rankedMembers = List.from(widget.members);
    _loadPeriodData();
  }

  Future<void> _loadPeriodData() async {
    setState(() => _isLoading = true);

    try {
      final DateTime now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case LeaderboardPeriod.today:
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case LeaderboardPeriod.week:
          // Lundi de cette semaine à 00:00:00
          final weekday = now.weekday; // 1 = lundi, 7 = dimanche
          startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
          break;
        case LeaderboardPeriod.month:
          startDate = DateTime(now.year, now.month, 1);
          break;
        case LeaderboardPeriod.year:
          startDate = DateTime(now.year, 1, 1);
          break;
        case LeaderboardPeriod.allTime:
          // Utiliser totalSteps pour tous les temps
          setState(() {
            _rankedMembers = List<UserModel>.from(widget.members)
              ..sort((a, b) => b.totalSteps.compareTo(a.totalSteps));
            _memberStepsMap = {}; // Vider la map pour allTime
            _isLoading = false;
          });
          return;
      }

      // Charger les pas pour la période sélectionnée
      final Map<String, int> memberPeriodSteps = {};
      
      for (final member in widget.members) {
        try {
          final steps = await _stepService.getTotalSteps(
            member.uid,
            startDate,
            now,
          );
          memberPeriodSteps[member.uid] = steps;
          debugPrint('${member.name}: $steps pas pour la période');
        } catch (e) {
          debugPrint('Erreur chargement pas pour ${member.name}: $e');
          memberPeriodSteps[member.uid] = 0;
        }
      }

      // Trier les membres par les pas de la période
      final sortedMembers = List<UserModel>.from(widget.members);
      sortedMembers.sort((a, b) {
        final stepsA = memberPeriodSteps[a.uid] ?? 0;
        final stepsB = memberPeriodSteps[b.uid] ?? 0;
        return stepsB.compareTo(stepsA);
      });

      setState(() {
        _rankedMembers = sortedMembers;
        _memberStepsMap = memberPeriodSteps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Classement - ${widget.groupName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs de période
          Container(
            color: AppColors.primary.withOpacity(0.1),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodTab('Jour', LeaderboardPeriod.today),
                  _buildPeriodTab('Semaine', LeaderboardPeriod.week),
                  _buildPeriodTab('Mois', LeaderboardPeriod.month),
                  _buildPeriodTab('Année', LeaderboardPeriod.year),
                  _buildPeriodTab('Tous', LeaderboardPeriod.allTime),
                ],
              ),
            ),
          ),

          // Header avec total de pas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _getPeriodTitle(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatNumber(_calculateTotalSteps()),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'pas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rankedMembers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rankedMembers.length,
                        itemBuilder: (context, index) {
                          final user = _rankedMembers[index];
                          final rank = index + 1;
                          final isCurrentUser = user.uid == widget.currentUserId;
                          final isAdmin = user.uid == widget.adminId;

                          // Afficher les pas de la période si disponible
                          final displaySteps = _selectedPeriod == LeaderboardPeriod.allTime
                              ? user.totalSteps
                              : (_memberStepsMap[user.uid] ?? 0);

                          // Créer une copie temporaire pour l'affichage
                          final displayUser = _selectedPeriod == LeaderboardPeriod.allTime
                              ? user
                              : UserModel(
                                  id: user.id,
                                  email: user.email,
                                  name: user.name,
                                  photoUrl: user.photoUrl,
                                  age: user.age,
                                  gender: user.gender,
                                  location: user.location,
                                  dailyGoal: user.dailyGoal,
                                  createdAt: user.createdAt,
                                  userLevel: user.userLevel,
                                  groupIds: user.groupIds,
                                  totalSteps: displaySteps,
                                  totalDistance: user.totalDistance,
                                  totalCalories: user.totalCalories,
                                  height: user.height,
                                  weight: user.weight,
                                );

                          return GroupMemberTile(
                            user: displayUser,
                            rank: rank,
                            isAdmin: isAdmin,
                            isCurrentUser: isCurrentUser,
                            onTap: isCurrentUser
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfileScreen(
                                          userId: user.uid,
                                          userProfile: user,
                                        ),
                                      ),
                                    );
                                  },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, LeaderboardPeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _loadPeriodData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case LeaderboardPeriod.today:
        return 'Total d\'Aujourd\'hui';
      case LeaderboardPeriod.week:
        return 'Total de la Semaine';
      case LeaderboardPeriod.month:
        return 'Total du Mois';
      case LeaderboardPeriod.year:
        return 'Total de l\'Année';
      case LeaderboardPeriod.allTime:
        return 'Total du Groupe';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun membre',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalSteps() {
    if (_selectedPeriod == LeaderboardPeriod.allTime) {
      return _rankedMembers.fold<int>(
        0,
        (total, user) => total + user.totalSteps,
      );
    } else {
      return _memberStepsMap.values.fold<int>(0, (total, steps) => total + steps);
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
