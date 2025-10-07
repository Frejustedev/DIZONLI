import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import 'group_member_tile.dart';

/// Widget displaying full group leaderboard
/// Shows all members ranked by total steps
class GroupLeaderboard extends StatelessWidget {
  final List<UserModel> members;
  final String currentUserId;
  final String adminId;
  final bool isCurrentUserAdmin;
  final Function(UserModel)? onMemberTap;
  final Function(UserModel)? onRemoveMember;

  const GroupLeaderboard({
    super.key,
    required this.members,
    required this.currentUserId,
    required this.adminId,
    this.isCurrentUserAdmin = false,
    this.onMemberTap,
    this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    // Sort members by totalSteps descending
    final sortedMembers = List<UserModel>.from(members)
      ..sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

    if (sortedMembers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Classement du Groupe',
                style: TextStyle(
                  fontSize: 20,
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
                  '${sortedMembers.length} membres',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Podium for top 3
        if (sortedMembers.length >= 3) _buildPodium(sortedMembers),

        const SizedBox(height: 16),

        // Full leaderboard
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedMembers.length,
          itemBuilder: (context, index) {
            final user = sortedMembers[index];
            final rank = index + 1;
            final isCurrentUser = user.uid == currentUserId;
            final isAdmin = user.uid == adminId;

            return GroupMemberTile(
              user: user,
              rank: rank,
              isAdmin: isAdmin,
              isCurrentUser: isCurrentUser,
              onTap: onMemberTap != null ? () => onMemberTap!(user) : null,
              onRemove: isCurrentUserAdmin && !isCurrentUser && !isAdmin
                  ? () => onRemoveMember?.call(user)
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPodium(List<UserModel> sortedMembers) {
    final first = sortedMembers.isNotEmpty ? sortedMembers[0] : null;
    final second = sortedMembers.length > 1 ? sortedMembers[1] : null;
    final third = sortedMembers.length > 2 ? sortedMembers[2] : null;

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd place
          if (second != null)
            Expanded(
              child: _buildPodiumPlace(
                user: second,
                rank: 2,
                height: 130,
                color: AppColors.silver,
              ),
            ),
          
          const SizedBox(width: 8),
          
          // 1st place
          if (first != null)
            Expanded(
              child: _buildPodiumPlace(
                user: first,
                rank: 1,
                height: 170,
                color: AppColors.gold,
              ),
            ),
          
          const SizedBox(width: 8),
          
          // 3rd place
          if (third != null)
            Expanded(
              child: _buildPodiumPlace(
                user: third,
                rank: 3,
                height: 110,
                color: AppColors.bronze,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace({
    required UserModel user,
    required int rank,
    required double height,
    required Color color,
  }) {
    final isCurrentUser = user.uid == currentUserId;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar with crown for 1st place
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '👑',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Name
        Text(
          isCurrentUser ? 'Vous' : user.name.split(' ').first,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        
        // Steps
        Text(
          _formatNumber(user.totalSteps),
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Podium
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              _getRankEmoji(rank),
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun membre dans ce groupe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invitez des amis à rejoindre le groupe!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
        return '$rank';
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

