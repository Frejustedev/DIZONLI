import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/challenge_service.dart';
import '../../services/step_service.dart';
import '../../services/user_service.dart';
import '../../models/challenge_model.dart';
import '../../models/user_model.dart';
import '../../models/step_record_model.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final StepService _stepService = StepService();
  final UserService _userService = UserService();

  Map<String, int> _participantsProgress = {};
  Map<String, UserModel> _participantsInfo = {};
  bool _isLoading = true;
  int _currentUserProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final currentUserId = userProvider.currentUser!.id;

      // Charger les informations de tous les participants
      for (String participantId in widget.challenge.participantIds) {
        // Charger les infos utilisateur
        final user = await _userService.getUser(participantId);
        if (user != null) {
          _participantsInfo[participantId] = user;
        }

        // Calculer la progression
        final progress = await _calculateProgress(
          participantId,
          widget.challenge.startDate,
          widget.challenge.endDate,
        );
        _participantsProgress[participantId] = progress;

        if (participantId == currentUserId) {
          _currentUserProgress = progress;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<int> _calculateProgress(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _stepService.getTotalSteps(userId, startDate, endDate);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.challenge.endDate.difference(DateTime.now()).inDays;
    final totalDays = widget.challenge.endDate.difference(widget.challenge.startDate).inDays;
    final daysElapsed = totalDays - daysRemaining;
    final progressPercent = (daysElapsed / totalDays * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
        backgroundColor: _getChallengeColor(),
        foregroundColor: Colors.white,
        actions: [
          if (_isParticipant())
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Quitter le défi',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'leave') {
                  _confirmLeaveChallenge();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChallengeDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du défi
                    _buildChallengeHeader(),
                    const SizedBox(height: 24),

                    // Progression temporelle
                    _buildTimeProgress(daysRemaining, totalDays, progressPercent),
                    const SizedBox(height: 24),

                    // Ma progression
                    if (_isParticipant()) ...[
                      _buildMyProgress(),
                      const SizedBox(height: 24),
                    ],

                    // Classement
                    _buildLeaderboard(),
                    const SizedBox(height: 24),

                    // Statistiques
                    _buildStatistics(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChallengeHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getChallengeColor(), _getChallengeColor().withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getChallengeIcon(),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.challenge.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getTypeLabel(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.challenge.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                widget.challenge.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  Icons.flag,
                  '${NumberFormat('#,###').format(widget.challenge.targetSteps)} pas',
                ),
                _buildInfoChip(
                  Icons.people,
                  '${widget.challenge.participantIds.length} ${widget.challenge.participantIds.length > 1 ? 'participants' : 'participant'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeProgress(int daysRemaining, int totalDays, double progressPercent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression temporelle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  daysRemaining > 0
                      ? '$daysRemaining ${daysRemaining > 1 ? 'jours restants' : 'jour restant'}'
                      : 'Terminé',
                  style: TextStyle(
                    fontSize: 14,
                    color: daysRemaining > 0 ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getChallengeColor()),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Début: ${DateFormat('dd/MM/yyyy').format(widget.challenge.startDate)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'Fin: ${DateFormat('dd/MM/yyyy').format(widget.challenge.endDate)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyProgress() {
    final progressPercent = (_currentUserProgress / widget.challenge.targetSteps * 100).clamp(0, 100);
    final isCompleted = _currentUserProgress >= widget.challenge.targetSteps;

    return Card(
      color: isCompleted ? AppColors.success.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ma progression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${NumberFormat('#,###').format(_currentUserProgress)} pas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
                Text(
                  '${progressPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 16,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isCompleted
                  ? '🎉 Objectif atteint ! Félicitations !'
                  : 'Objectif: ${NumberFormat('#,###').format(widget.challenge.targetSteps)} pas',
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? AppColors.success : AppColors.textSecondary,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    // Trier les participants par progression
    final sortedParticipants = _participantsProgress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Classement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedParticipants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = sortedParticipants[index];
                final userId = entry.key;
                final steps = entry.value;
                final user = _participantsInfo[userId];
                final rank = index + 1;

                if (user == null) return const SizedBox();

                final progressPercent = (steps / widget.challenge.targetSteps * 100).clamp(0, 100);
                final isCurrentUser = userId == context.read<UserProvider>().currentUser?.id;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? AppColors.primary.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Rang
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankColor(rank),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: rank <= 3
                              ? Text(
                                  _getRankEmoji(rank),
                                  style: const TextStyle(fontSize: 20),
                                )
                              : Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar et nom
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 6),
                                  const Text(
                                    '(Vous)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${NumberFormat('#,###').format(steps)} pas',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${progressPercent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Badge si objectif atteint
                      if (steps >= widget.challenge.targetSteps)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final totalSteps = _participantsProgress.values.fold<int>(0, (sum, steps) => sum + steps);
    final averageSteps = _participantsProgress.isNotEmpty
        ? (totalSteps / _participantsProgress.length).round()
        : 0;
    final completedCount = _participantsProgress.values.where(
      (steps) => steps >= widget.challenge.targetSteps,
    ).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    NumberFormat('#,###').format(totalSteps),
                    Icons.directions_walk,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Moyenne',
                    NumberFormat('#,###').format(averageSteps),
                    Icons.analytics,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Ont atteint l\'objectif',
              '$completedCount / ${widget.challenge.participantIds.length}',
              Icons.emoji_events,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isParticipant() {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    return currentUserId != null && widget.challenge.participantIds.contains(currentUserId);
  }

  Color _getChallengeColor() {
    switch (widget.challenge.type) {
      case ChallengeType.individual:
        return AppColors.primary;
      case ChallengeType.team:
        return AppColors.secondary;
      case ChallengeType.competitive:
        return AppColors.accent;
      case ChallengeType.collaborative:
        return AppColors.success;
    }
  }

  IconData _getChallengeIcon() {
    switch (widget.challenge.type) {
      case ChallengeType.individual:
        return Icons.person;
      case ChallengeType.team:
        return Icons.groups;
      case ChallengeType.competitive:
        return Icons.emoji_events;
      case ChallengeType.collaborative:
        return Icons.favorite;
    }
  }

  String _getTypeLabel() {
    switch (widget.challenge.type) {
      case ChallengeType.individual:
        return 'Défi individuel';
      case ChallengeType.team:
        return 'Défi d\'équipe';
      case ChallengeType.competitive:
        return 'Défi compétitif';
      case ChallengeType.collaborative:
        return 'Défi collaboratif';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return Colors.grey;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  Future<void> _confirmLeaveChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le défi ?'),
        content: Text(
          'Voulez-vous vraiment quitter "${widget.challenge.title}" ?\n\nVotre progression sera perdue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = context.read<UserProvider>().currentUser!.id;
        await _challengeService.leaveChallenge(widget.challenge.id, userId);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous avez quitté le défi'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }
}
