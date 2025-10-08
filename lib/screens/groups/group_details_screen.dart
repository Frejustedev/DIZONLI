import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../services/group_service.dart';
import '../../services/user_service.dart';
import '../../services/step_service.dart';
import 'edit_group_screen.dart';
import 'full_leaderboard_screen.dart';

/// Screen displaying group details and leaderboard
class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

enum GroupPeriod { day, week, month, year, total }

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GroupService _groupService = GroupService();
  final UserService _userService = UserService();
  final StepService _stepService = StepService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  late TabController _tabController;
  List<UserModel> _members = [];
  bool _isLoading = true;
  GroupPeriod _selectedPeriod = GroupPeriod.week;
  Map<String, int> _memberStepsForPeriod = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all member profiles
      final members = <UserModel>[];
      for (final memberId in widget.group.members) {
        try {
          final userSnapshot = await _userService.getUser(memberId);
          if (userSnapshot != null) {
            members.add(userSnapshot);
          }
        } catch (e) {
          // Skip user if not found
          continue;
        }
      }

      setState(() {
        _members = members;
      });

      // Charger les pas pour la période sélectionnée
      await _loadStepsForPeriod();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _loadStepsForPeriod() async {
    final stepsMap = <String, int>{};
    final now = DateTime.now();

    for (final member in _members) {
      int steps = 0;

      try {
      switch (_selectedPeriod) {
        case GroupPeriod.day:
          // Pas d'aujourd'hui
            final startOfDay = DateTime(now.year, now.month, now.day);
            steps = await _stepService.getTotalSteps(member.uid, startOfDay, now);
          break;

        case GroupPeriod.week:
            // Pas de la semaine (du lundi à aujourd'hui)
            final weekday = now.weekday; // 1 = lundi, 7 = dimanche
            final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
            steps = await _stepService.getTotalSteps(member.uid, startOfWeek, now);
          break;

        case GroupPeriod.month:
          // Pas du mois en cours
          final startOfMonth = DateTime(now.year, now.month, 1);
            steps = await _stepService.getTotalSteps(member.uid, startOfMonth, now);
          break;

        case GroupPeriod.year:
          // Pas de l'année en cours
          final startOfYear = DateTime(now.year, 1, 1);
            steps = await _stepService.getTotalSteps(member.uid, startOfYear, now);
          break;

        case GroupPeriod.total:
          // Total de tous les temps
          steps = member.totalSteps;
          break;
        }
      } catch (e) {
        debugPrint('Erreur chargement pas pour ${member.name}: $e');
        steps = 0;
      }

      stepsMap[member.uid] = steps;
    }

    setState(() {
      _memberStepsForPeriod = stepsMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.adminId == _currentUserId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Group Header
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.group.name,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      widget.group.isPrivate ? Icons.lock : Icons.public,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    if (widget.group.description != null && widget.group.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.group.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'invite',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 12),
                          Text('Partager le code'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 12),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _leaveGroup,
                  tooltip: 'Quitter le groupe',
                ),
            ],
          ),

          // Period Selector
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildPeriodSelector(),
            ),
          ),

          // Stats Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.people,
                    value: '${widget.group.members.length}',
                    label: 'Membres',
                    color: AppColors.primary,
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.divider,
                  ),
                  _buildStatColumn(
                    icon: Icons.directions_walk,
                    value: _formatNumber(_calculateTotalSteps()),
                    label: 'Pas ${_getPeriodLabel()}',
                    color: AppColors.secondary,
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.divider,
                  ),
                  _buildStatColumn(
                    icon: Icons.vpn_key,
                    value: widget.group.inviteCode ?? 'N/A',
                    label: 'Code',
                    color: AppColors.accent,
                    onTap: () => _copyInviteCode(widget.group.inviteCode ?? ''),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.leaderboard),
                    text: 'Classement',
                  ),
                  Tab(
                    icon: Icon(Icons.info),
                    text: 'Infos',
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Leaderboard Tab
                      _buildLeaderboardTab(),
                      // Info Tab
                      _buildInfoTab(isAdmin),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPeriodButton('Jour', GroupPeriod.day),
          _buildPeriodButton('Semaine', GroupPeriod.week),
          _buildPeriodButton('Mois', GroupPeriod.month),
          _buildPeriodButton('Année', GroupPeriod.year),
          _buildPeriodButton('Total', GroupPeriod.total),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, GroupPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (_selectedPeriod != period) {
            setState(() {
              _selectedPeriod = period;
            });
            await _loadStepsForPeriod();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    // Trier les membres par pas de la période sélectionnée
    final sortedMembers = List<UserModel>.from(_members)
      ..sort((a, b) {
        final stepsA = _memberStepsForPeriod[a.uid] ?? 0;
        final stepsB = _memberStepsForPeriod[b.uid] ?? 0;
        return stepsB.compareTo(stepsA);
      });
    
    // Top 3
    final top3 = sortedMembers.take(3).toList();

    return RefreshIndicator(
      onRefresh: _loadMembers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top 3 du Groupe',
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

            const SizedBox(height: 16),

            // Podium pour top 3
            if (top3.length >= 3) _buildPodium(top3),

            const SizedBox(height: 32),

            // Bouton "Voir tout le classement"
            if (sortedMembers.length > 3)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullLeaderboardScreen(
                          members: _members,
                          currentUserId: _currentUserId,
                          adminId: widget.group.adminId,
                          groupName: widget.group.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('Voir tout le classement'),
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
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<UserModel> top3) {
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return SizedBox(
      height: 250, // Augmenté pour éviter overflow
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2ème place
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
          
          // 1ère place
          Expanded(
            child: _buildPodiumPlace(
              user: first,
              rank: 1,
              height: 170,
              color: AppColors.gold,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 3ème place
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
    final isCurrentUser = user.uid == _currentUserId;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar avec couronne pour 1er
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
        
        // Nom
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
        
        // Pas
        Text(
          _formatNumber(_memberStepsForPeriod[user.uid] ?? 0),
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

  Widget _buildInfoTab(bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Info Card
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
                  _buildInfoRow(
                    icon: Icons.group,
                    label: 'Nom du groupe',
                    value: widget.group.name,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: widget.group.isPrivate ? Icons.lock : Icons.public,
                    label: 'Type',
                    value: widget.group.isPrivate ? 'Privé' : 'Public',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Créé le',
                    value: _formatDate(widget.group.createdAt),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Administrateur',
                    value: _getAdminName(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Invite Code Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _copyInviteCode(widget.group.inviteCode ?? ''),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vpn_key, color: AppColors.primary),
                        SizedBox(width: 12),
                        Text(
                          'Code d\'invitation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.group.inviteCode ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 6,
                            ),
                          ),
                          const Icon(
                            Icons.copy,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toucher pour copier',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Leave/Delete Group Button
          if (!isAdmin)
            ElevatedButton.icon(
              onPressed: _leaveGroup,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Quitter le groupe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAdminName() {
    final admin = _members.firstWhere(
      (member) => member.id == widget.group.adminId,
      orElse: () => UserModel(
        id: '',
        name: 'Inconnu',
        email: '',
        age: 0,
        gender: '',
        location: '',
        totalSteps: 0,
        dailyGoal: 10000,
        createdAt: DateTime.now(),
      ),
    );
    return admin.name;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  int _calculateTotalSteps() {
    return _memberStepsForPeriod.values.fold<int>(0, (sum, steps) => sum + steps);
  }
  
  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case GroupPeriod.day:
        return 'aujourd\'hui';
      case GroupPeriod.week:
        return 'cette semaine';
      case GroupPeriod.month:
        return 'ce mois';
      case GroupPeriod.year:
        return 'cette année';
      case GroupPeriod.total:
        return 'total';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié dans le presse-papier!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invite':
        _shareInviteCode();
        break;
      case 'edit':
        _editGroup();
        break;
      case 'delete':
        _deleteGroup();
        break;
    }
  }

  void _shareInviteCode() async {
    try {
      final message = '''
🎉 Rejoins mon groupe "${widget.group.name}" sur DIZONLI!

📱 Code d'invitation: ${widget.group.inviteCode}

DIZONLI est une application de suivi d'activité physique et de défis sportifs.
Télécharge l'app et utilise ce code pour nous rejoindre!

🚶 Marchons ensemble vers une meilleure santé!
''';

      await Share.share(
        message,
        subject: 'Invitation groupe DIZONLI - ${widget.group.name}',
      );
    } catch (e) {
      // Fallback: copier le code
      _copyInviteCode(widget.group.inviteCode ?? '');
    }
  }

  void _editGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupScreen(group: widget.group),
      ),
    );
    
    // Si des modifications ont été faites, recharger les données
    if (result == true) {
      setState(() {
        _loadMembers();
      });
    }
  }

  void _deleteGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.group.name}" ?\n\n'
          'Cette action est irréversible et tous les membres perdront accès au groupe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _groupService.deleteGroup(widget.group.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Groupe supprimé'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le groupe'),
        content: Text(
          'Voulez-vous vraiment quitter "${widget.group.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _groupService.removeGroupMember(
                  widget.group.id,
                  _currentUserId,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vous avez quitté le groupe'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

}

// Helper class for pinned tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

