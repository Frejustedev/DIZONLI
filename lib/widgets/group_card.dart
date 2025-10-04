import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/group_model.dart';

/// Widget card displaying group information
/// Shows group name, member count, total steps, and admin status
class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;
  final bool isAdmin;

  const GroupCard({
    Key? key,
    required this.group,
    required this.onTap,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Group Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      group.isPrivate ? Icons.lock : Icons.public,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Group Name and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAdmin) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.isPrivate ? 'Groupe privé' : 'Groupe public',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  // Members
                  Expanded(
                    child: _buildStat(
                      icon: Icons.people,
                      value: '${group.members.length}',
                      label: 'Membres',
                      color: AppColors.primary,
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider,
                  ),
                  
                  // Total Steps
                  Expanded(
                    child: _buildStat(
                      icon: Icons.directions_walk,
                      value: _formatNumber(group.totalSteps),
                      label: 'Pas',
                      color: AppColors.secondary,
                    ),
                  ),
                  
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider,
                  ),
                  
                  // Created Date
                  Expanded(
                    child: _buildStat(
                      icon: Icons.calendar_today,
                      value: _formatDate(group.createdAt),
                      label: 'Créé',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              
              // Description if available
              if (group.description != null && group.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  group.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return "Auj.";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}j";
    } else if (difference.inDays < 30) {
      return "${(difference.inDays / 7).floor()}sem";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()}mois";
    } else {
      return "${(difference.inDays / 365).floor()}ans";
    }
  }
}

