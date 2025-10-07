import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

/// Écran de paramètres de l'application
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  bool _notificationsEnabled = true;
  bool _badgeNotifications = true;
  bool _friendNotifications = true;
  bool _challengeNotifications = true;
  bool _profilePublic = true;
  int _dailyGoal = 10000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      setState(() {
        _dailyGoal = user.dailyGoal;
        // TODO: Charger les préférences depuis Firestore si disponibles
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Section Profil
          _buildSectionHeader('Profil'),
          _buildProfileTile(user),
          const Divider(height: 1),

          // Section Objectifs
          _buildSectionHeader('Objectifs'),
          _buildDailyGoalTile(),
          const Divider(height: 1),

          // Section Notifications
          _buildSectionHeader('Notifications'),
          _buildNotificationsTile(),
          const Divider(height: 1),

          // Section Confidentialité
          _buildSectionHeader('Confidentialité'),
          _buildPrivacyTile(),
          const Divider(height: 1),

          // Section À propos
          _buildSectionHeader('À propos'),
          _buildAboutTiles(),
          const Divider(height: 1),

          // Section Compte
          _buildSectionHeader('Compte'),
          _buildAccountTiles(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileTile(user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.2),
        backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user?.photoUrl == null || user!.photoUrl!.isEmpty
            ? Text(
                user?.name[0].toUpperCase() ?? '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user?.name ?? 'Utilisateur',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(user?.email ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Navigate to edit profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Édition du profil - À venir')),
        );
      },
    );
  }

  Widget _buildDailyGoalTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.flag, color: AppColors.primary),
      ),
      title: const Text(
        'Objectif quotidien',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('$_dailyGoal pas par jour'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDailyGoalDialog(),
    );
  }

  Widget _buildNotificationsTile() {
    return Column(
      children: [
        SwitchListTile(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
          title: const Text(
            'Activer les notifications',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: const Text('Recevoir des notifications'),
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications, color: AppColors.secondary),
          ),
          activeColor: AppColors.primary,
        ),
        if (_notificationsEnabled) ...[
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: const Text('Badges'),
            trailing: Switch(
              value: _badgeNotifications,
              onChanged: (value) {
                setState(() => _badgeNotifications = value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: const Text('Demandes d\'ami'),
            trailing: Switch(
              value: _friendNotifications,
              onChanged: (value) {
                setState(() => _friendNotifications = value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: const Text('Défis'),
            trailing: Switch(
              value: _challengeNotifications,
              onChanged: (value) {
                setState(() => _challengeNotifications = value);
              },
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyTile() {
    return SwitchListTile(
      value: _profilePublic,
      onChanged: (value) {
        setState(() => _profilePublic = value);
        _updatePrivacySettings(value);
      },
      title: const Text(
        'Profil public',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _profilePublic
            ? 'Votre profil est visible par tous'
            : 'Seuls vos amis peuvent voir votre profil',
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _profilePublic ? Icons.public : Icons.lock,
          color: AppColors.accent,
        ),
      ),
      activeColor: AppColors.primary,
    );
  }

  Widget _buildAboutTiles() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline),
          ),
          title: const Text('Version'),
          subtitle: const Text('1.0.0+1'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showAboutDialog(),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined),
          ),
          title: const Text('Conditions d\'utilisation'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to terms
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CGU - À venir')),
            );
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.privacy_tip_outlined),
          ),
          title: const Text('Politique de confidentialité'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Politique de confidentialité - À venir')),
            );
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.contact_support_outlined),
          ),
          title: const Text('Nous contacter'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Open email client
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact: support@dizonli.app')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountTiles() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.logout, color: Colors.orange),
          ),
          title: const Text(
            'Déconnexion',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.orange),
          onTap: () => _confirmLogout(),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          title: const Text(
            'Supprimer le compte',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.red),
          onTap: () => _confirmDeleteAccount(),
        ),
      ],
    );
  }

  void _showDailyGoalDialog() {
    int tempGoal = _dailyGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Objectif quotidien'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tempGoal.toString()} pas',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: tempGoal.toDouble(),
                min: 5000,
                max: 20000,
                divisions: 30,
                activeColor: AppColors.primary,
                label: tempGoal.toString(),
                onChanged: (value) {
                  setDialogState(() {
                    tempGoal = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5 000',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '20 000',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateDailyGoal(tempGoal);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'DIZONLI',
      applicationVersion: '1.0.0+1',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.directions_walk,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Application de suivi d\'activité physique et de défis sportifs.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2025 DIZONLI. Tous droits réservés.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées.\n\nÊtes-vous absolument sûr?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suppression de compte - À implémenter'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDailyGoal(int newGoal) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await _userService.updateUser(userId, {'dailyGoal': newGoal});
      
      setState(() {
        _dailyGoal = newGoal;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Objectif mis à jour!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePrivacySettings(bool isPublic) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // TODO: Implement privacy settings in UserModel
      // await _userService.updateUser(userId, {'profilePublic': isPublic});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPublic
                  ? '✅ Profil maintenant public'
                  : '✅ Profil maintenant privé',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
