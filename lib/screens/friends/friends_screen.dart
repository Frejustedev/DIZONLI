import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/friendship_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../models/friendship_model.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendshipService _friendshipService = FriendshipService();
  final UserService _userService = UserService();
  
  List<UserModel> _friends = [];
  List<FriendshipModel> _pendingRequests = [];
  List<FriendshipModel> _sentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final userProvider = context.read<UserProvider>();
    if (userProvider.currentUser == null) return;
    
    final userId = userProvider.currentUser!.id;

    try {
      // Charger les amis
      final friends = await _userService.getFriends(userId);
      
      // Charger les demandes reçues
      final pending = await _friendshipService.getPendingRequests(userId);
      
      // Charger les demandes envoyées
      final sent = await _friendshipService.getSentRequests(userId);

      setState(() {
        _friends = friends;
        _pendingRequests = pending;
        _sentRequests = sent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${_friends.length}'),
                child: const Icon(Icons.people),
              ),
              text: 'Mes amis',
            ),
            Tab(
              icon: Badge(
                label: Text('${_pendingRequests.length}'),
                isLabelVisible: _pendingRequests.isNotEmpty,
                child: const Icon(Icons.person_add),
              ),
              text: 'Demandes',
            ),
            Tab(
              icon: Badge(
                label: Text('${_sentRequests.length}'),
                isLabelVisible: _sentRequests.isNotEmpty,
                child: const Icon(Icons.send),
              ),
              text: 'Envoyées',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Rechercher des amis',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildPendingRequestsList(),
                _buildSentRequestsList(),
              ],
            ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'Aucun ami',
        subtitle: 'Recherchez des utilisateurs pour les ajouter',
        action: ElevatedButton.icon(
          onPressed: _showSearchDialog,
          icon: const Icon(Icons.person_search),
          label: const Text('Rechercher des amis'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return _buildFriendCard(friend);
        },
      ),
    );
  }

  Widget _buildFriendCard(UserModel friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            friend.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${friend.totalSteps} pas'),
            Text(friend.location, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('Voir le profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Retirer', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              _confirmRemoveFriend(friend);
            } else if (value == 'view') {
              // TODO: Navigate to friend profile
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profil de ${friend.name}')),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPendingRequestsList() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'Aucune demande',
        subtitle: 'Vous n\'avez pas de demandes d\'ami en attente',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return _buildPendingRequestCard(request);
        },
      ),
    );
  }

  Widget _buildPendingRequestCard(FriendshipModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: FutureBuilder<UserModel?>(
        future: _userService.getUser(request.senderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ListTile(
              leading: CircleAvatar(child: CircularProgressIndicator()),
              title: Text('Chargement...'),
            );
          }

          final sender = snapshot.data!;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                sender.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              sender.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(sender.location),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.success),
                  onPressed: () => _acceptRequest(request),
                  tooltip: 'Accepter',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.error),
                  onPressed: () => _rejectRequest(request),
                  tooltip: 'Refuser',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSentRequestsList() {
    if (_sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_outlined,
        title: 'Aucune demande envoyée',
        subtitle: 'Recherchez des utilisateurs pour envoyer des demandes',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentRequests.length,
        itemBuilder: (context, index) {
          final request = _sentRequests[index];
          return _buildSentRequestCard(request);
        },
      ),
    );
  }

  Widget _buildSentRequestCard(FriendshipModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: FutureBuilder<UserModel?>(
        future: _userService.getUser(request.receiverId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ListTile(
              leading: CircleAvatar(child: CircularProgressIndicator()),
              title: Text('Chargement...'),
            );
          }

          final receiver = snapshot.data!;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text(
                receiver.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(receiver.name),
            subtitle: const Text('En attente...', style: TextStyle(fontStyle: FontStyle.italic)),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: AppColors.error),
              onPressed: () => _cancelRequest(request),
              tooltip: 'Annuler',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _SearchFriendsDialog(
        onRequestSent: () {
          _loadData();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _acceptRequest(FriendshipModel request) async {
    try {
      await _friendshipService.acceptFriendRequest(request.id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ami ajouté !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(FriendshipModel request) async {
    try {
      await _friendshipService.rejectFriendRequest(request.id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _cancelRequest(FriendshipModel request) async {
    try {
      await _friendshipService.cancelFriendRequest(request.id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande annulée'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _confirmRemoveFriend(UserModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer cet ami ?'),
        content: Text('Voulez-vous vraiment retirer ${friend.name} de vos amis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userProvider = context.read<UserProvider>();
        await _friendshipService.removeFriend(
          userProvider.currentUser!.id,
          friend.id,
        );
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend.name} retiré de vos amis'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }
}

// Dialog de recherche d'amis
class _SearchFriendsDialog extends StatefulWidget {
  final VoidCallback onRequestSent;

  const _SearchFriendsDialog({required this.onRequestSent});

  @override
  State<_SearchFriendsDialog> createState() => _SearchFriendsDialogState();
}

class _SearchFriendsDialogState extends State<_SearchFriendsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final FriendshipService _friendshipService = FriendshipService();
  
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await _userService.searchUsersByEmail(query);
      
      // Filtrer l'utilisateur actuel
      final currentUser = context.read<UserProvider>().currentUser;
      final filtered = results.where((user) => user.id != currentUser?.id).toList();

      setState(() {
        _searchResults = filtered;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(UserModel user) async {
    try {
      final currentUser = context.read<UserProvider>().currentUser!;
      await _friendshipService.sendFriendRequest(currentUser.id, user.id);
      
      widget.onRequestSent();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Demande envoyée à ${user.name}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rechercher des amis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Email de l\'utilisateur',
                prefixIcon: const Icon(Icons.email),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_hasSearched && _searchResults.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else if (_searchResults.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _sendFriendRequest(user),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
