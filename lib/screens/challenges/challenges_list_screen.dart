import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';
import '../../widgets/challenge_card.dart';
import 'create_challenge_screen.dart';
import 'challenge_details_screen.dart';

/// Screen displaying list of challenges
class ChallengesListScreen extends StatefulWidget {
  const ChallengesListScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesListScreen> createState() => _ChallengesListScreenState();
}

class _ChallengesListScreenState extends State<ChallengesListScreen>
    with SingleTickerProviderStateMixin {
  final ChallengeService _challengeService = ChallengeService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Défis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Mes Défis'),
            Tab(text: 'Actifs'),
            Tab(text: 'À venir'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyChallengesTab(),
          _buildActiveChallengesTab(),
          _buildUpcomingChallengesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateChallenge,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Créer un Défi'),
      ),
    );
  }

  Widget _buildMyChallengesTab() {
    return StreamBuilder<List<ChallengeModel>>(
      stream: _challengeService.streamUserChallenges(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.emoji_events,
            title: 'Aucun défi',
            message:
                'Vous ne participez à aucun défi.\nCréez-en un ou rejoignez-en un existant!',
            actionLabel: 'Découvrir les défis',
            onAction: () => _tabController.animateTo(1),
          );
        }

        // Group challenges by status
        final active = challenges
            .where((c) => c.status == ChallengeStatus.active)
            .toList();
        final completed = challenges
            .where((c) => c.isCompletedBy(_currentUserId))
            .toList();
        final other = challenges
            .where((c) =>
                c.status != ChallengeStatus.active &&
                !c.isCompletedBy(_currentUserId))
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                _buildSectionHeader('En cours', active.length),
                ...active.map((challenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ChallengeCard(
                        challenge: challenge,
                        currentUserId: _currentUserId,
                        onTap: () => _navigateToChallengeDetails(challenge),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                _buildSectionHeader('Complétés', completed.length),
                ...completed.map((challenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ChallengeCard(
                        challenge: challenge,
                        currentUserId: _currentUserId,
                        onTap: () => _navigateToChallengeDetails(challenge),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (other.isNotEmpty) ...[
                _buildSectionHeader('Autres', other.length),
                ...other.map((challenge) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ChallengeCard(
                        challenge: challenge,
                        currentUserId: _currentUserId,
                        onTap: () => _navigateToChallengeDetails(challenge),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveChallengesTab() {
    return StreamBuilder<List<ChallengeModel>>(
      stream: _challengeService.streamPublicChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final challenges = snapshot.data ?? [];
        final activeChallenges = challenges
            .where((c) => c.status == ChallengeStatus.active)
            .toList();

        if (activeChallenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off,
            title: 'Aucun défi actif',
            message: 'Il n\'y a pas de défis publics actifs pour le moment.',
            actionLabel: 'Créer un défi',
            onAction: _navigateToCreateChallenge,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeChallenges.length,
            itemBuilder: (context, index) {
              final challenge = activeChallenges[index];
              final isParticipating =
                  challenge.participantIds.contains(_currentUserId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    ChallengeCard(
                      challenge: challenge,
                      currentUserId:
                          isParticipating ? _currentUserId : null,
                      onTap: () => _navigateToChallengeDetails(challenge),
                    ),
                    if (!isParticipating)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ElevatedButton.icon(
                          onPressed: () => _joinChallenge(challenge),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Rejoindre'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingChallengesTab() {
    return StreamBuilder<List<ChallengeModel>>(
      stream: _challengeService.streamUpcomingChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.schedule,
            title: 'Aucun défi à venir',
            message: 'Aucun défi n\'est planifié pour le moment.',
            actionLabel: 'Créer un défi',
            onAction: _navigateToCreateChallenge,
          );
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
              final daysUntilStart =
                  challenge.startDate.difference(DateTime.now()).inDays;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    ChallengeCard(
                      challenge: challenge,
                      currentUserId: null,
                      onTap: () => _navigateToChallengeDetails(challenge),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Dans $daysUntilStart jours',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            'Erreur: $error',
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

  void _navigateToChallengeDetails(ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailsScreen(challenge: challenge),
      ),
    );
  }

  void _navigateToCreateChallenge() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateChallengeScreen(),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Défi créé avec succès!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _joinChallenge(ChallengeModel challenge) async {
    try {
      await _challengeService.joinChallenge(challenge.id, _currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez rejoint le défi!'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {});
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
}

