import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Écran hub social regroupant Actualités, Groupes et Amis
class SocialHubScreen extends StatelessWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue dans votre espace social !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accédez à toutes vos interactions en un seul endroit',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Actualités Card
            _buildSocialCard(
              context,
              icon: Icons.feed,
              title: 'Actualités',
              subtitle: 'Voir le fil d\'actualités et les posts',
              color: AppColors.accent,
              onTap: () => Navigator.pushNamed(context, '/social'),
            ),
            const SizedBox(height: 12),
            
            // Groupes Card
            _buildSocialCard(
              context,
              icon: Icons.groups,
              title: 'Groupes',
              subtitle: 'Rejoindre et gérer vos groupes',
              color: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, '/groups'),
            ),
            const SizedBox(height: 12),
            
            // Amis Card
            _buildSocialCard(
              context,
              icon: Icons.people,
              title: 'Amis',
              subtitle: 'Gérer vos amis et demandes',
              color: AppColors.secondary,
              onTap: () => Navigator.pushNamed(context, '/friends'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
