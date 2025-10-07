import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/challenge_model.dart';

/// Widget displaying detailed challenge progress
class ChallengeProgress extends StatelessWidget {
  final ChallengeModel challenge;
  final String userId;
  final bool showLeaderboard;

  const ChallengeProgress({
    super.key,
    required this.challenge,
    required this.userId,
    this.showLeaderboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final userProgress = challenge.progress[userId] ?? 0;
    final percentage = challenge.getProgressPercentage(userId);
    final isCompleted = challenge.isCompletedBy(userId);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Votre progression',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Complété!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Circular Progress Indicator
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.divider.withOpacity(0.2),
                      ),
                    ),
                    // Progress circle
                    CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatProgress(userProgress),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'sur ${_formatProgress(challenge.targetValue)}',
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
            ),
            
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: _formatProgress(userProgress - (challenge.progress[userId] ?? 0)),
                  label: 'Aujourd\'hui',
                  color: AppColors.accent,
                ),
                _buildStatItem(
                  icon: Icons.flag,
                  value: _formatProgress(challenge.targetValue - userProgress),
                  label: 'Restant',
                  color: AppColors.secondary,
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  value: '${challenge.daysRemaining}j',
                  label: 'Temps',
                  color: AppColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Linear Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$userProgress / ${challenge.targetValue}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.divider.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            // Leaderboard preview
            if (showLeaderboard && challenge.participantIds.length > 1) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Classement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_getUserRank()} / ${challenge.participantIds.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLeaderboardPreview(),
            ],
            
            // Motivation message
            if (!isCompleted) ...[
              const SizedBox(height: 20),
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
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMotivationIcon(percentage),
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getMotivationMessage(percentage),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview() {
    final sortedProgress = challenge.progress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topThree = sortedProgress.take(3).toList();
    
    return Column(
      children: topThree.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final progressEntry = entry.value;
        final isCurrentUser = progressEntry.key == userId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Text(
                _getRankEmoji(rank),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCurrentUser ? 'Vous' : 'Participant $rank',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _formatProgress(progressEntry.value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _getUserRank() {
    final sortedProgress = challenge.progress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedProgress.indexWhere((e) => e.key == userId) + 1;
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
        return '$rank.';
    }
  }

  String _formatProgress(int value) {
    switch (challenge.type) {
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
        return '$value jours';
    }
  }

  IconData _getMotivationIcon(double percentage) {
    if (percentage >= 75) return Icons.rocket_launch;
    if (percentage >= 50) return Icons.trending_up;
    if (percentage >= 25) return Icons.directions_run;
    return Icons.flag;
  }

  String _getMotivationMessage(double percentage) {
    if (percentage >= 90) {
      return 'Presque là! Plus que quelques pas!';
    } else if (percentage >= 75) {
      return 'Excellent travail! Continuez comme ça!';
    } else if (percentage >= 50) {
      return 'À mi-chemin! Vous pouvez le faire!';
    } else if (percentage >= 25) {
      return 'Bon début! Gardez le rythme!';
    } else {
      return 'C\'est parti! Chaque pas compte!';
    }
  }
}

