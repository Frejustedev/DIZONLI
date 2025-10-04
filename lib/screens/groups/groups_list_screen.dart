import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../widgets/group_card.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';
import 'group_details_screen.dart';

/// Screen displaying list of user's groups and option to create/join groups
class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({Key? key}) : super(key: key);

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final GroupService _groupService = GroupService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Groupes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Rechercher un groupe',
          ),
        ],
      ),
      body: StreamBuilder<List<GroupModel>>(
        stream: _groupService.streamUserGroups(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final isAdmin = group.adminId == _currentUserId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GroupCard(
                    group: group,
                    isAdmin: isAdmin,
                    onTap: () => _navigateToGroupDetails(group),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _navigateToJoinGroup,
            heroTag: 'join',
            backgroundColor: AppColors.secondary,
            child: const Icon(Icons.group_add),
            tooltip: 'Rejoindre un groupe',
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _navigateToCreateGroup,
            heroTag: 'create',
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add),
            label: const Text('Créer'),
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
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucun groupe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Créez un groupe ou rejoignez-en un pour commencer à vous challenger avec vos amis!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _navigateToCreateGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Créer un groupe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _navigateToJoinGroup,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Rejoindre'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGroupDetails(GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsScreen(group: group),
      ),
    );
  }

  void _navigateToCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Groupe créé avec succès!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _navigateToJoinGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinGroupScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le groupe!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un groupe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Nom du groupe...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                Navigator.pop(context);
                _searchGroups(value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Ou rejoignez un groupe avec son code d\'invitation',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToJoinGroup();
            },
            child: const Text('Code d\'invitation'),
          ),
        ],
      ),
    );
  }

  void _searchGroups(String query) {
    // TODO: Implement group search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recherche de groupes à venir...'),
      ),
    );
  }
}

