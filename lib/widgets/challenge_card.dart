import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/challenge_model.dart';

/// Widget card displaying challenge information
class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final String? currentUserId;
  final VoidCallback onTap;

  const ChallengeCard({
    Key? key,
    required this.challenge,
    this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProgress = currentUserId != null
        ? challenge.getProgressPercentage(currentUserId!)
        : 0.0;
    final isCompleted = currentUserId != null &&
        challenge.isCompletedBy(currentUserId!);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getStatusGradient(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: _getStatusColor(),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Title and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusBadge(),
                              const SizedBox(width: 8),
                              _buildScopeBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Completion badge
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Progress Bar (if user is participating)
                if (currentUserId != null &&
                    challenge.participantIds.contains(currentUserId)) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: userProgress / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? AppColors.success : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${userProgress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      Icons.flag,
                      _formatTarget(),
                      'Objectif',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.people,
                      '${challenge.participantIds.length}',
                      'Participants',
                    ),
                    const Spacer(),
                    if (challenge.status == ChallengeStatus.active)
                      _buildStatItem(
                        Icons.timer,
                        '${challenge.daysRemaining}j',
                        'Restant',
                      ),
                  ],
                ),
                
                // Reward info
                if (challenge.rewardPoints > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+${challenge.rewardPoints} points',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (challenge.status) {
      case ChallengeStatus.active:
        return LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeStatus.upcoming:
        return LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeStatus.completed:
        return LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ChallengeStatus.failed:
        return LinearGradient(
          colors: [Colors.grey, Colors.grey.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getStatusColor() {
    switch (challenge.status) {
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

  IconData _getTypeIcon() {
    switch (challenge.type) {
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

  Widget _buildStatusBadge() {
    String statusText;
    switch (challenge.status) {
      case ChallengeStatus.active:
        statusText = 'En cours';
        break;
      case ChallengeStatus.upcoming:
        statusText = 'À venir';
        break;
      case ChallengeStatus.completed:
        statusText = 'Terminé';
        break;
      case ChallengeStatus.failed:
        statusText = 'Échoué';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildScopeBadge() {
    String scopeText;
    IconData icon;
    
    switch (challenge.scope) {
      case ChallengeScope.personal:
        scopeText = 'Personnel';
        icon = Icons.person;
        break;
      case ChallengeScope.group:
        scopeText = 'Groupe';
        icon = Icons.group;
        break;
      case ChallengeScope.friends:
        scopeText = 'Amis';
        icon = Icons.people;
        break;
      case ChallengeScope.global:
        scopeText = 'Global';
        icon = Icons.public;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            scopeText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatTarget() {
    switch (challenge.type) {
      case ChallengeType.steps:
        if (challenge.targetValue >= 1000) {
          return '${(challenge.targetValue / 1000).toStringAsFixed(0)}k';
        }
        return '${challenge.targetValue}';
      case ChallengeType.distance:
        return '${challenge.targetValue} km';
      case ChallengeType.duration:
        return '${challenge.targetValue} min';
      case ChallengeType.streak:
        return '${challenge.targetValue} jours';
    }
  }
}

