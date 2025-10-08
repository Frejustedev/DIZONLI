import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/badge_model.dart';
import '../../providers/badge_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/badge_tile.dart';
import '../../widgets/badge_detail_card.dart';

/// Écran d'affichage des badges
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BadgeCategory? _selectedCategory;
  BadgeRarity? _selectedRarity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Charger les badges après que le widget soit monté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBadges();
    });
  }

  Future<void> _loadBadges() async {
    if (!mounted) return;
    
    final badgeProvider = context.read<BadgeProvider>();
    final userProvider = context.read<UserProvider>();

    await badgeProvider.loadAllBadges();
    if (mounted && userProvider.currentUser != null) {
      // ✅ DÉBLOQUER AUTOMATIQUEMENT LES BADGES
      await badgeProvider.checkAndUnlockBadges(userProvider.currentUser!.id);
      // Charger les badges de l'utilisateur (déjà fait dans checkAndUnlockBadges si de nouveaux badges)
      if (mounted) {
        await badgeProvider.loadUserBadges(userProvider.currentUser!.id);
      }
    }
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
        title: const Text('Badges'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Débloqués', icon: Icon(Icons.check_circle)),
            Tab(text: 'Tous', icon: Icon(Icons.collections_bookmark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<BadgeProvider>(
        builder: (context, badgeProvider, child) {
          if (badgeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (badgeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${badgeProvider.error}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBadges,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats Header
              _buildStatsHeader(badgeProvider),

              // Badge List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBadgeList(
                      badgeProvider.userBadges,
                      badgeProvider,
                      unlockedOnly: true,
                    ),
                    _buildBadgeList(
                      badgeProvider.allBadges,
                      badgeProvider,
                      unlockedOnly: false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(BadgeProvider badgeProvider) {
    final stats = badgeProvider.getBadgeStats();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                label: 'Débloqués',
                value: '${stats['unlocked']}/${stats['total']}',
                color: Colors.white,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem(
                icon: Icons.lock_open,
                label: 'Progression',
                value: '${stats['percentage'].toStringAsFixed(0)}%',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: stats['percentage'] / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeList(
    List<BadgeModel> badges,
    BadgeProvider badgeProvider, {
    required bool unlockedOnly,
  }) {
    var filteredBadges = badges;

    // Apply category filter
    if (_selectedCategory != null) {
      filteredBadges = filteredBadges
          .where((badge) => badge.category == _selectedCategory)
          .toList();
    }

    // Apply rarity filter
    if (_selectedRarity != null) {
      filteredBadges = filteredBadges
          .where((badge) => badge.rarity == _selectedRarity)
          .toList();
    }

    if (filteredBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlockedOnly ? Icons.lock_open : Icons.collections_bookmark,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              unlockedOnly
                  ? 'Aucun badge débloqué pour le moment'
                  : 'Aucun badge disponible',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBadges,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: filteredBadges.length,
        itemBuilder: (context, index) {
          final badge = filteredBadges[index];
          final isUnlocked = badgeProvider.isBadgeUnlocked(badge.id);

          return BadgeTile(
            badge: badge,
            isUnlocked: isUnlocked,
            onTap: () => _showBadgeDetail(badge, isUnlocked),
          );
        },
      ),
    );
  }

  void _showBadgeDetail(BadgeModel badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailCard(
        badge: badge,
        isUnlocked: isUnlocked,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les badges'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catégorie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Tous',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...BadgeCategory.values.map(
                  (category) => _buildFilterChip(
                    label: _getCategoryLabel(category),
                    isSelected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Rareté',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Tous',
                  isSelected: _selectedRarity == null,
                  onTap: () => setState(() => _selectedRarity = null),
                ),
                ...BadgeRarity.values.map(
                  (rarity) => _buildFilterChip(
                    label: _getRarityLabel(rarity),
                    isSelected: _selectedRarity == rarity,
                    onTap: () => setState(() => _selectedRarity = rarity),
                    color: _getRarityColor(rarity),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedRarity = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color ?? AppColors.primary,
      checkmarkColor: color != null ? Colors.white : null,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _getCategoryLabel(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.achievement:
        return 'Exploit';
      case BadgeCategory.milestone:
        return 'Étape';
      case BadgeCategory.social:
        return 'Social';
    }
  }

  String _getRarityLabel(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Commun';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Épique';
      case BadgeRarity.legendary:
        return 'Légendaire';
    }
  }

  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }
}

