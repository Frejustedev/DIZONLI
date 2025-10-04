import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/social_provider.dart';
import '../../models/user_model.dart';
import '../../models/friendship_model.dart';
import '../../services/friendship_service.dart';

/// Écran de gestion des amis
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendshipService _friendshipService = FriendshipService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser != null) {
        final socialProvider = context.read<SocialProvider>();
        socialProvider.loadFriends(userProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
        title: const Text('Amis'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes amis', icon: Icon(Icons.people)),
            Tab(text: 'Demandes', icon: Icon(Icons.notifications)),
            Tab(text: 'Rechercher', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(currentUser.id),
          _buildPendingRequests(currentUser.id),
          _buildSearchTab(currentUser.id),
        ],
      ),
    );
  }

  Widget _buildFriendsList(String userId) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final friends = socialProvider.friends;

        if (socialProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (friends.isEmpty) {
          return _buildEmptyState(
            'Aucun ami pour le moment',
            'Recherchez des utilisateurs et envoyez des demandes d\'ami !',
            Icons.people_outline,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await socialProvider.loadFriends(userId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendTile(friend, userId);
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingRequests(String userId) {
    return StreamBuilder<List<FriendshipModel>>(
      stream: _friendshipService.streamPendingRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            'Aucune demande en attente',
            'Vous n\'avez pas de nouvelles demandes d\'ami.',
            Icons.notifications_none,
          );
        }

        final requests = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestTile(request, userId);
          },
        );
      },
    );
  }

  Widget _buildSearchTab(String currentUserId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher des utilisateurs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _performSearch(value, currentUserId),
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty && _searchController.text.isEmpty
              ? _buildEmptyState(
                  'Recherchez des amis',
                  'Entrez un nom pour commencer la recherche.',
                  Icons.search,
                )
              : _searchResults.isEmpty
                  ? _buildEmptyState(
                      'Aucun résultat',
                      'Aucun utilisateur ne correspond à votre recherche.',
                      Icons.person_off,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return _buildSearchResultTile(user, currentUserId);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFriendTile(UserModel friend, String currentUserId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: friend.photoUrl != null && friend.photoUrl!.isNotEmpty
              ? NetworkImage(friend.photoUrl!)
              : null,
          child: friend.photoUrl == null || friend.photoUrl!.isEmpty
              ? Text(
                  friend.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        title: Text(
          friend.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${friend.totalSteps} pas',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showFriendOptions(friend, currentUserId),
        ),
      ),
    );
  }

  Widget _buildRequestTile(FriendshipModel request, String currentUserId) {
    return FutureBuilder<UserModel?>(
      future: _friendshipService.getUserProfile(request.requesterId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final requester = snapshot.data!;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: requester.photoUrl != null && requester.photoUrl!.isNotEmpty
                  ? NetworkImage(requester.photoUrl!)
                  : null,
              child: requester.photoUrl == null || requester.photoUrl!.isEmpty
                  ? Text(
                      requester.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            title: Text(
              requester.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${requester.totalSteps} pas',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: () => _acceptRequest(currentUserId, requester.id),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => _declineRequest(currentUserId, requester.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultTile(UserModel user, String currentUserId) {
    return FutureBuilder<FriendshipStatus?>(
      future: _friendshipService.checkFriendshipStatus(currentUserId, user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Chargement...'),
            ),
          );
        }

        final status = snapshot.data;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${user.totalSteps} pas',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: _buildActionButton(status, currentUserId, user.id),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      FriendshipStatus? status, String currentUserId, String targetUserId) {
    if (status == null) {
      // Pas d'amitié existante
      return ElevatedButton.icon(
        onPressed: () => _sendFriendRequest(currentUserId, targetUserId),
        icon: const Icon(Icons.person_add, size: 18),
        label: const Text('Ajouter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      );
    }

    switch (status) {
      case FriendshipStatus.pending:
        return const Chip(
          label: Text('En attente'),
          backgroundColor: AppColors.warning,
        );
      case FriendshipStatus.accepted:
        return const Chip(
          label: Text('Amis'),
          backgroundColor: AppColors.success,
          avatar: Icon(Icons.check, color: Colors.white, size: 18),
        );
      case FriendshipStatus.blocked:
        return const Chip(
          label: Text('Bloqué'),
          backgroundColor: AppColors.error,
        );
    }
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query, String currentUserId) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final socialProvider = context.read<SocialProvider>();
      final results = await socialProvider.searchUsers(query, currentUserId);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de recherche: $e')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      final socialProvider = context.read<SocialProvider>();
      await socialProvider.sendFriendRequest(fromUserId, toUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande d\'ami envoyée !'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {}); // Refresh to update button state
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

  Future<void> _acceptRequest(String userId, String friendId) async {
    try {
      final socialProvider = context.read<SocialProvider>();
      await socialProvider.acceptFriendRequest(userId, friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée !'),
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

  Future<void> _declineRequest(String userId, String friendId) async {
    try {
      final socialProvider = context.read<SocialProvider>();
      await socialProvider.declineFriendRequest(userId, friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande refusée')),
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

  void _showFriendOptions(UserModel friend, String currentUserId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove, color: AppColors.error),
              title: const Text('Supprimer cet ami'),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(currentUserId, friend.id, friend.name);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFriend(String userId, String friendId, String friendName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet ami ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer $friendName de vos amis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final socialProvider = context.read<SocialProvider>();
        await socialProvider.removeFriend(userId, friendId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ami supprimé')),
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
  }
}

