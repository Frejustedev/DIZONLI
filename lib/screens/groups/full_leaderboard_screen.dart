import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../widgets/group_member_tile.dart';

/// Écran affichant le classement complet du groupe
class FullLeaderboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Trier les membres par totalSteps décroissant
    final sortedMembers = List<UserModel>.from(members)
      ..sort((a, b) => b.totalSteps.compareTo(a.totalSteps));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Classement - $groupName'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: sortedMembers.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
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
                      const Text(
                        'Total du Groupe',
                        style: TextStyle(
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
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
                      );
                    },
                  ),
                ),
              ],
            ),
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
          ],
        ),
      ),
    );
  }

  int _calculateTotalSteps() {
    return members.fold<int>(
      0,
      (sum, member) => sum + member.totalSteps,
    );
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
