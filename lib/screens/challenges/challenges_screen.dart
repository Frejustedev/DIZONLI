import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/challenge_card.dart';
import 'package:intl/intl.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChallengeService _challengeService = ChallengeService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.challenges),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Défis publics', icon: Icon(Icons.public)),
            Tab(text: 'Mes défis', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublicChallenges(currentUser.id),
          _buildUserChallenges(currentUser.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateChallengeDialog(currentUser.id),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Créer un défi'),
      ),
    );
  }

  Widget _buildPublicChallenges(String userId) {
    return StreamBuilder<List<ChallengeModel>>(
      stream: _challengeService.streamPublicChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState('Aucun défi public pour le moment');
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return ChallengeCard(
                challenge: challenge,
                currentUserId: userId,
                onTap: () => _showChallengeDetails(challenge, userId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUserChallenges(String userId) {
    return StreamBuilder<List<ChallengeModel>>(
      stream: _challengeService.streamUserChallenges(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState('Vous ne participez à aucun défi');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return ChallengeCard(
              challenge: challenge,
              currentUserId: userId,
              onTap: () => _showChallengeDetails(challenge, userId),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showChallengeDetails(ChallengeModel challenge, String userId) {
    // TODO: Navigate to challenge details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détails du défi: ${challenge.title}')),
    );
  }

  void _showCreateChallengeDialog(String userId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final goalController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    ChallengeType selectedType = ChallengeType.steps;
    ChallengeScope selectedScope = ChallengeScope.personal;
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer un défi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du défi',
                    hintText: 'Ex: Marathon de Mars',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez votre défi...',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type de défi',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ChallengeType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getChallengeTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeScope>(
                  value: selectedScope,
                  decoration: const InputDecoration(
                    labelText: 'Portée du défi',
                    prefixIcon: Icon(Icons.people),
                  ),
                  items: ChallengeScope.values.map((scope) {
                    return DropdownMenuItem(
                      value: scope,
                      child: Text(_getChallengeScopeName(scope)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedScope = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: goalController,
                  decoration: InputDecoration(
                    labelText: 'Objectif',
                    hintText: _getChallengeGoalHint(selectedType),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(startDate == null
                      ? 'Date de début'
                      : 'Début: ${DateFormat('dd/MM/yyyy').format(startDate!)}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(endDate == null
                      ? 'Date de fin'
                      : 'Fin: ${DateFormat('dd/MM/yyyy').format(endDate!)}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => endDate = date);
                    }
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: isPublic,
                  onChanged: (value) => setState(() => isPublic = value),
                  title: const Text('Défi public'),
                  subtitle: Text(isPublic
                      ? 'Visible par tous'
                      : 'Privé (invitation uniquement)'),
                  secondary: Icon(
                    isPublic ? Icons.public : Icons.lock,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    goalController.text.isEmpty ||
                    startDate == null ||
                    endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final challenge = ChallengeModel(
                  id: '',
                  title: titleController.text,
                  description: descriptionController.text,
                  type: selectedType,
                  scope: selectedScope,
                  targetValue: int.parse(goalController.text),
                  startDate: startDate!,
                  endDate: endDate!,
                  creatorId: userId,
                  participantIds: [userId],
                  progress: {userId: 0},
                  isPublic: isPublic,
                  createdAt: DateTime.now(),
                );

                try {
                  await _challengeService.createChallenge(challenge);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Défi créé avec succès !'),
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
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return 'Nombre de pas';
      case ChallengeType.distance:
        return 'Distance';
      case ChallengeType.duration:
        return 'Durée';
      case ChallengeType.streak:
        return 'Série de jours';
    }
  }

  String _getChallengeScopeName(ChallengeScope scope) {
    switch (scope) {
      case ChallengeScope.personal:
        return 'Personnel';
      case ChallengeScope.group:
        return 'Groupe';
      case ChallengeScope.friends:
        return 'Amis';
      case ChallengeScope.global:
        return 'Global';
    }
  }

  String _getChallengeGoalHint(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return 'Ex: 100000 pas';
      case ChallengeType.distance:
        return 'Ex: 50 km';
      case ChallengeType.duration:
        return 'Ex: 300 minutes';
      case ChallengeType.streak:
        return 'Ex: 30 jours';
    }
  }
}
