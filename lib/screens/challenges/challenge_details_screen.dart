import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';
import '../../widgets/challenge_progress.dart';

/// Screen displaying challenge details and leaderboard
class ChallengeDetailsScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailsScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  final ChallengeService _challengeService = ChallengeService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isParticipating = false;

  @override
  void initState() {
    super.initState();
    _isParticipating = widget.challenge.participantIds.contains(_currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChallengeModel?>(
      stream: _challengeService.streamChallenge(widget.challenge.id),
      builder: (context, snapshot) {
        final challenge = snapshot.data ?? widget.challenge;
        final isCompleted = challenge.isCompletedBy(_currentUserId);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar with Header
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: _getStatusColor(challenge.status),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    challenge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Color.fromARGB(128, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getStatusColor(challenge.status),
                          _getStatusColor(challenge.status).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          _getTypeIcon(challenge.type),
                          size: 60,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(height: 16),
                        if (challenge.rewardPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${challenge.rewardPoints} points',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (challenge.creatorId == _currentUserId)
                    PopupMenuButton<String>(
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: AppColors.error),
                              SizedBox(width: 12),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                challenge.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Début',
                                _formatDate(challenge.startDate),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.event,
                                'Fin',
                                _formatDate(challenge.endDate),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.people,
                                'Participants',
                                '${challenge.participantIds.length}',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.check_circle,
                                'Taux de réussite',
                                '${challenge.completionRate.toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Progress (if participating)
                      if (_isParticipating)
                        ChallengeProgress(
                          challenge: challenge,
                          userId: _currentUserId,
                          showLeaderboard: true,
                        ),

                      const SizedBox(height: 16),

                      // Full Leaderboard
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Classement Complet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${challenge.completedCount} / ${challenge.participantIds.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildLeaderboard(challenge),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildActionButton(challenge, isCompleted),
        );
      },
    );
  }

  Widget? _buildActionButton(ChallengeModel challenge, bool isCompleted) {
    if (challenge.status != ChallengeStatus.active) return null;

    if (!_isParticipating) {
      return FloatingActionButton.extended(
        onPressed: _joinChallenge,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Rejoindre'),
      );
    }

    if (isCompleted) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.check_circle),
        label: const Text('Complété!'),
      );
    }

    return FloatingActionButton.extended(
      onPressed: _leaveChallenge,
      backgroundColor: AppColors.error,
      icon: const Icon(Icons.exit_to_app),
      label: const Text('Quitter'),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(ChallengeModel challenge) {
    final sortedProgress = challenge.progress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedProgress.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun participant pour le moment',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedProgress.length,
      itemBuilder: (context, index) {
        final entry = sortedProgress[index];
        final rank = index + 1;
        final isCurrentUser = entry.key == _currentUserId;
        final percentage = (entry.value / challenge.targetValue * 100).clamp(0, 100);
        final isCompleted = entry.value >= challenge.targetValue;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isCurrentUser
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 40,
                child: Text(
                  _getRankDisplay(rank),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(rank),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Participant
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCurrentUser ? 'Vous' : 'Participant $rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Progress
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatProgress(entry.value, challenge.type),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (isCompleted) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getRankDisplay(int rank) {
    if (rank <= 3) {
      return ['🥇', '🥈', '🥉'][rank - 1];
    }
    return '$rank.';
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
        return AppColors.textSecondary;
    }
  }

  String _formatProgress(int value, ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}k';
        }
        return '$value';
      case ChallengeType.distance:
        return '$value km';
      case ChallengeType.duration:
        return '$value min';
      case ChallengeType.streak:
        return '$value j';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return Icons.directions_walk;
      case ChallengeType.distance:
        return Icons.straighten;
      case ChallengeType.duration:
        return Icons.timer;
      case ChallengeType.streak:
        return Icons.local_fire_department;
    }
  }

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return AppColors.primary;
      case ChallengeStatus.upcoming:
        return AppColors.secondary;
      case ChallengeStatus.completed:
        return AppColors.success;
      case ChallengeStatus.failed:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    if (action == 'delete') {
      _deleteChallenge();
    }
  }

  void _deleteChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le défi'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce défi ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _challengeService.deleteChallenge(widget.challenge.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Défi supprimé'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _joinChallenge() async {
    try {
      await _challengeService.joinChallenge(
        widget.challenge.id,
        _currentUserId,
      );
      setState(() {
        _isParticipating = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le défi!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _leaveChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le défi'),
        content: const Text('Voulez-vous vraiment quitter ce défi ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _challengeService.leaveChallenge(
                  widget.challenge.id,
                  _currentUserId,
                );
                setState(() {
                  _isParticipating = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vous avez quitté le défi'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }
}

