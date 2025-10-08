import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/user_helper.dart';
import '../../models/user_model.dart';
import '../../models/step_record_model.dart';
import '../../services/friendship_service.dart';
import '../../services/step_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/stat_card.dart';

/// Écran de profil utilisateur (ami ou non-ami)
class UserProfileScreen extends StatefulWidget {
  final String userId;
  final UserModel? userProfile; // Optionnel si déjà chargé

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userProfile,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FriendshipService _friendshipService = FriendshipService();
  final StepService _stepService = StepService();
  
  bool _isLoading = true;
  bool _areFriends = false;
  bool _hasPendingRequest = false;
  UserModel? _userProfile;
  List<StepRecordModel> _weekData = [];
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = context.read<UserProvider>().currentUser?.uid ?? '';
      
      // Charger le profil utilisateur
      _userProfile = widget.userProfile;
      
      // Vérifier le statut d'amitié
      _areFriends = await _friendshipService.areFriends(
        currentUserId,
        widget.userId,
      );
      
      _hasPendingRequest = await _friendshipService.hasPendingRequest(
        currentUserId,
        widget.userId,
      );

      // Si ami, charger les stats détaillées
      if (_areFriends) {
        final weekData = await _stepService.getWeekSteps(widget.userId);
        final streak = await _stepService.getStreak(
          widget.userId,
          _userProfile?.dailyGoal ?? 10000,
        );

        setState(() {
          _weekData = weekData;
          _streak = streak;
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(
          child: Text('Utilisateur introuvable'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar avec photo de profil
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _userProfile!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: (_userProfile!.photoUrl != null && _userProfile!.photoUrl!.isNotEmpty)
                            ? NetworkImage(_userProfile!.photoUrl!)
                            : null,
                        child: (_userProfile!.photoUrl == null || _userProfile!.photoUrl!.isEmpty)
                            ? Text(
                                _userProfile!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Si pas ami : bouton envoyer demande
                  if (!_areFriends) ...[
                    _buildNonFriendView(),
                  ],
                  
                  // Si ami : profil complet
                  if (_areFriends) ...[
                    _buildFriendView(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonFriendView() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.lock,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          'Profil privé',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Devenez ami pour voir le profil complet de ${_userProfile!.name.split(' ').first}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        
        // Bouton envoyer demande
        if (_hasPendingRequest)
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.schedule),
            label: const Text('Demande envoyée'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _sendFriendRequest,
            icon: const Icon(Icons.person_add),
            label: const Text('Envoyer une demande d\'ami'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFriendView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations physiques (Poids, Taille, IMC)
        if (_userProfile!.height != null || _userProfile!.weight != null) ...[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.monitor_weight,
                          color: AppColors.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Informations physiques',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_userProfile!.height != null)
                        Expanded(
                          child: _buildPhysicalInfo(
                            icon: Icons.height,
                            label: 'Taille',
                            value: '${_userProfile!.height!.toStringAsFixed(0)} cm',
                          ),
                        ),
                      if (_userProfile!.height != null && _userProfile!.weight != null)
                        const SizedBox(width: 12),
                      if (_userProfile!.weight != null)
                        Expanded(
                          child: _buildPhysicalInfo(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Poids',
                            value: '${_userProfile!.weight!.toStringAsFixed(1)} kg',
                          ),
                        ),
                    ],
                  ),
                  if (_userProfile!.bmi != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getBMIColor(_userProfile!.bmi!).withOpacity(0.2),
                            _getBMIColor(_userProfile!.bmi!).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getBMIColor(_userProfile!.bmi!),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getBMIColor(_userProfile!.bmi!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.monitor_heart_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Indice de Masse Corporelle (IMC)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _userProfile!.bmi!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: _getBMIColor(_userProfile!.bmi!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getBMIColor(_userProfile!.bmi!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getBMICategory(_userProfile!.bmi!),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
          const SizedBox(height: 16),
        ],

        // Stats principales
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_walk,
                title: 'Total Pas',
                value: _formatNumber(_userProfile!.totalSteps),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.track_changes,
                title: 'Streak',
                value: '$_streak jours',
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.straighten,
                title: 'Distance',
                value: '${(_userProfile!.totalDistance / 1000).toStringAsFixed(1)} km',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '${_userProfile!.totalCalories}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Activité de la semaine
        const Text(
          'Activité de la semaine',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildWeekChart(),
        const SizedBox(height: 24),

        // Objectif quotidien
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objectif quotidien',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatNumber(_userProfile!.dailyGoal)} pas',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPhysicalInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Maigreur';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  Widget _buildWeekChart() {
    if (_weekData.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    final maxSteps = _weekData.fold<int>(
      0,
      (max, record) => record.steps > max ? record.steps : max,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final record = index < _weekData.length
                    ? _weekData[index]
                    : null;
                final steps = record?.steps ?? 0;
                final height = maxSteps > 0
                    ? (steps / maxSteps) * 100
                    : 5.0;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatNumber(steps),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: height.clamp(10.0, 100.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ['L', 'M', 'M', 'J', 'V', 'S', 'D'][index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFriendRequest() async {
    try {
      final currentUserId = context.read<UserProvider>().currentUser?.uid ?? '';
      
      await _friendshipService.sendFriendRequest(
        currentUserId,
        widget.userId,
      );

      setState(() {
        _hasPendingRequest = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Demande d\'ami envoyée à ${_userProfile!.name.split(' ').first}!',
            ),
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
