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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CreateChallengeScreen(userId: userId),
        fullscreenDialog: true,
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

// Écran de création de défi en plein écran
class _CreateChallengeScreen extends StatefulWidget {
  final String userId;

  const _CreateChallengeScreen({required this.userId});

  @override
  State<_CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<_CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  final ChallengeService _challengeService = ChallengeService();
  
  DateTime? _startDate;
  DateTime? _endDate;
  ChallengeType _selectedType = ChallengeType.steps;
  ChallengeScope _selectedScope = ChallengeScope.personal;
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _createChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de début et fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final goalValue = int.tryParse(_goalController.text);
    if (goalValue == null || goalValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'objectif doit être un nombre positif'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final challenge = ChallengeModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        scope: _selectedScope,
        targetValue: goalValue,
        startDate: _startDate!,
        endDate: _endDate!,
        creatorId: widget.userId,
        participantIds: [widget.userId],
        progress: {widget.userId: 0},
        isPublic: _isPublic,
        createdAt: DateTime.now(),
      );

      await _challengeService.createChallenge(challenge);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Défi créé avec succès !'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un défi'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec icône
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Créez votre défi personnalisé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Marchez et progressez chaque jour',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Carte Informations principales
                _buildSectionCard(
                  title: '📝 Informations',
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du défi *',
                        hintText: 'Ex: Marathon de Mars',
                        prefixIcon: const Icon(Icons.title, color: AppColors.secondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est requis';
                        }
                        if (value.trim().length < 3) {
                          return 'Le titre doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Décrivez votre défi...',
                        prefixIcon: const Icon(Icons.description, color: AppColors.secondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Carte Type et Portée
                _buildSectionCard(
                  title: '🎯 Configuration',
                  children: [
                    DropdownButtonFormField<ChallengeType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type de défi *',
                        prefixIcon: const Icon(Icons.category, color: AppColors.accent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ChallengeType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(_getChallengeTypeIcon(type), size: 20),
                              const SizedBox(width: 8),
                              Text(_getChallengeTypeName(type)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ChallengeScope>(
                      value: _selectedScope,
                      decoration: InputDecoration(
                        labelText: 'Portée du défi *',
                        prefixIcon: const Icon(Icons.people, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ChallengeScope.values.map((scope) {
                        return DropdownMenuItem(
                          value: scope,
                          child: Row(
                            children: [
                              Icon(_getChallengeScopeIcon(scope), size: 20),
                              const SizedBox(width: 8),
                              Text(_getChallengeScopeName(scope)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedScope = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalController,
                      decoration: InputDecoration(
                        labelText: 'Objectif *',
                        hintText: _getChallengeGoalHint(_selectedType),
                        prefixIcon: const Icon(Icons.flag, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixText: _getChallengeUnit(_selectedType),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'objectif est requis';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Entrez un nombre positif';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Carte Dates
                _buildSectionCard(
                  title: '📅 Période',
                  children: [
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _startDate != null ? AppColors.primary.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _startDate != null ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _startDate != null ? AppColors.primary : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date de début *',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _startDate != null
                                        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(_startDate!)
                                        : 'Sélectionnez une date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _startDate != null ? AppColors.primary : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _startDate != null ? Icons.check_circle : Icons.arrow_forward_ios,
                              color: _startDate != null ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
      context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _endDate != null ? AppColors.accent.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _endDate != null ? AppColors.accent : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: _endDate != null ? AppColors.accent : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date de fin *',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _endDate != null
                                        ? DateFormat('dd MMMM yyyy', 'fr_FR').format(_endDate!)
                                        : 'Sélectionnez une date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _endDate != null ? AppColors.accent : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _endDate != null ? Icons.check_circle : Icons.arrow_forward_ios,
                              color: _endDate != null ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 20, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Text(
                                'Durée: ${_endDate!.difference(_startDate!).inDays + 1} jours',
                                style: const TextStyle(
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
                const SizedBox(height: 20),

                // Carte Visibilité
                _buildSectionCard(
                  title: '🌍 Visibilité',
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _isPublic ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isPublic ? AppColors.primary : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: SwitchListTile(
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                        title: Text(
                          _isPublic ? 'Défi Public' : 'Défi Privé',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _isPublic
                              ? 'Visible par tous les utilisateurs'
                              : 'Visible uniquement sur invitation',
                          style: const TextStyle(fontSize: 12),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isPublic ? AppColors.primary : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPublic ? Icons.public : Icons.lock,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppColors.error, width: 2),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Créer le défi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  IconData _getChallengeTypeIcon(ChallengeType type) {
    switch (type) {
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

  IconData _getChallengeScopeIcon(ChallengeScope scope) {
    switch (scope) {
      case ChallengeScope.personal:
        return Icons.person;
      case ChallengeScope.group:
        return Icons.groups;
      case ChallengeScope.friends:
        return Icons.people;
      case ChallengeScope.global:
        return Icons.public;
    }
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
        return 'Ex: 100000';
      case ChallengeType.distance:
        return 'Ex: 50';
      case ChallengeType.duration:
        return 'Ex: 300';
      case ChallengeType.streak:
        return 'Ex: 30';
    }
  }

  String _getChallengeUnit(ChallengeType type) {
    switch (type) {
      case ChallengeType.steps:
        return 'pas';
      case ChallengeType.distance:
        return 'km';
      case ChallengeType.duration:
        return 'min';
      case ChallengeType.streak:
        return 'jours';
    }
  }
}
