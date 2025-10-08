import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/user_helper.dart';
import '../../services/friendship_service.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../../models/friendship_model.dart';
import '../../models/user_model.dart';
import 'add_friend_screen.dart';
import '../profile/user_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);
  
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendshipService _friendshipService = FriendshipService();
  final UserService _userService = UserService();
  
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
        title: const Text('Mes Amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Amis', icon: Icon(Icons.people)),
            Tab(text: 'Demandes', icon: Icon(Icons.person_add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(currentUser.uid),
          _buildRequestsList(currentUser.uid),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddFriendScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
    );
  }
  
  Widget _buildFriendsList(String userId) {
    return StreamBuilder<List<String>>(
      stream: _friendshipService.streamFriends(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'Aucun ami',
            subtitle: 'Ajoutez des amis pour commencer!',
          );
        }
        
        final friendIds = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: () async {
            // Force le rebuild du stream
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friendIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<UserModel?>(
                future: _userService.getUser(friendIds[index]),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text('Chargement...'),
                      ),
                    );
                  }
                  
                  final friend = userSnapshot.data!;
                  return _buildFriendTile(friend);
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildRequestsList(String userId) {
    return StreamBuilder<List<FriendshipModel>>(
      stream: _friendshipService.streamPendingRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox,
            title: 'Aucune demande',
            subtitle: 'Vous n\'avez pas de demandes d\'amis en attente',
          );
        }
        
        final requests = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final requesterId = request.requesterId;
              
              return FutureBuilder<UserModel?>(
                future: _userService.getUser(requesterId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Icon(Icons.person)),
                        title: Text('Chargement...'),
                      ),
                    );
                  }
                  
                  final requester = userSnapshot.data!;
                  return _buildRequestTile(requester, request);
                },
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildFriendTile(UserModel friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: friend.photoURL.isNotEmpty
              ? NetworkImage(friend.photoURL)
              : null,
          child: friend.photoURL.isEmpty
              ? Text(
                  friend.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          '${friend.firstName} ${friend.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${_formatNumber(friend.totalSteps)} pas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'remove') {
              _confirmRemoveFriend(friend);
            } else if (value == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userId: friend.uid,
                    userProfile: friend,
                  ),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('Voir profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Retirer ami', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestTile(UserModel requester, FriendshipModel friendship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.secondary.withOpacity(0.2),
          backgroundImage: requester.photoURL.isNotEmpty
              ? NetworkImage(requester.photoURL)
              : null,
          child: requester.photoURL.isEmpty
              ? Text(
                  requester.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.secondary,
                  ),
                )
              : null,
        ),
        title: Text(
          '${requester.firstName} ${requester.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: const Text(
          'Demande d\'ami',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              onPressed: () => _acceptRequest(friendship),
              tooltip: 'Accepter',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
              onPressed: () => _rejectRequest(friendship),
              tooltip: 'Refuser',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmRemoveFriend(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ami'),
        content: Text(
          'Êtes-vous sûr de vouloir retirer ${friend.firstName} ${friend.lastName} de vos amis?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(friend);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _acceptRequest(FriendshipModel friendship) async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.currentUser?.uid;
    
    if (currentUserId == null) return;
    
    try {
      // Détermine l'ID de l'ami (l'autre personne dans la relation)
      final friendId = friendship.userId1 == currentUserId 
          ? friendship.userId2 
          : friendship.userId1;
      
      await _friendshipService.acceptFriendRequest(currentUserId, friendId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande acceptée!'),
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
  
  Future<void> _rejectRequest(FriendshipModel friendship) async {
    try {
      await _friendshipService.deleteFriendship(friendship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée'),
            backgroundColor: Colors.orange,
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
  
  Future<void> _removeFriend(UserModel friend) async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.currentUser?.uid;
    
    if (currentUserId == null) return;
    
    try {
      await _friendshipService.removeFriend(currentUserId, friend.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.firstName} retiré de vos amis'),
            backgroundColor: Colors.orange,
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
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
