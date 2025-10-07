# 🚀 DÉMARRAGE IMMÉDIAT - DIZONLI

**Date:** 7 Octobre 2025  
**Pour:** Développeur prêt à corriger l'application  
**Temps de lecture:** 3 minutes

---

## ⚡ QUICK START - PAR OÙ COMMENCER?

Vous venez de lire l'analyse complète. Voici **exactement** quoi faire maintenant, dans l'ordre :

---

## 📋 ÉTAPE 1: NETTOYAGE IMMÉDIAT (30 minutes)

### Action 1.1: Supprimer les fichiers dupliqués

```bash
# Dans le terminal, depuis la racine du projet:

# Supprimer le service dupliqué
rm lib/services/group_service_NEW.dart

# Supprimer l'ancien dashboard
rm lib/screens/dashboard/dashboard_screen.dart

# Renommer la version v2
mv lib/screens/dashboard/dashboard_screen_v2.dart lib/screens/dashboard/dashboard_screen.dart
```

### Action 1.2: Vérifier les importations

```bash
# Chercher les références aux anciens fichiers
grep -r "group_service_NEW" lib/
grep -r "dashboard_screen_v2" lib/

# Si des fichiers trouvés, les éditer et remplacer:
# - group_service_NEW.dart → group_service.dart
# - dashboard_screen_v2.dart → dashboard_screen.dart
```

### Action 1.3: Tester la compilation

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

**✅ Checkpoint:** L'app doit compiler et démarrer sans erreurs.

---

## 📋 ÉTAPE 2: CRÉER ÉCRAN FRIENDS (4 heures)

### Structure à créer:

```
lib/screens/friends/
├── friends_screen.dart          # Écran principal avec tabs
├── add_friend_screen.dart       # Recherche et ajout
└── friend_requests_screen.dart  # Demandes en attente (optionnel)
```

### Fichier 1: `lib/screens/friends/friends_screen.dart`

Copiez ce template de base:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/friendship_service.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../../models/friendship_model.dart';
import '../../models/user_model.dart';
import 'add_friend_screen.dart';

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
    final currentUser = userProvider.user;
    
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
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friendIds.length,
          itemBuilder: (context, index) {
            return FutureBuilder<UserModel?>(
              future: _userService.getUser(friendIds[index]),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final friend = userSnapshot.data!;
                return _buildFriendTile(friend);
              },
            );
          },
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
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final requesterId = request.requesterId;
            
            return FutureBuilder<UserModel?>(
              future: _userService.getUser(requesterId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final requester = userSnapshot.data!;
                return _buildRequestTile(requester, request);
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildFriendTile(UserModel friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: friend.photoURL.isNotEmpty
              ? NetworkImage(friend.photoURL)
              : null,
          child: friend.photoURL.isEmpty
              ? Text(
                  friend.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text('${friend.firstName} ${friend.lastName}'),
        subtitle: Text('${friend.totalSteps} pas'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showFriendOptions(friend),
        ),
      ),
    );
  }
  
  Widget _buildRequestTile(UserModel requester, FriendshipModel friendship) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withOpacity(0.2),
          backgroundImage: requester.photoURL.isNotEmpty
              ? NetworkImage(requester.photoURL)
              : null,
          child: requester.photoURL.isEmpty
              ? Text(
                  requester.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                )
              : null,
        ),
        title: Text('${requester.firstName} ${requester.lastName}'),
        subtitle: const Text('Demande d\'ami'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _acceptRequest(friendship),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectRequest(friendship),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  void _showFriendOptions(UserModel friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: const Text('Retirer ami'),
                onTap: () {
                  Navigator.pop(context);
                  _removeFriend(friend);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _acceptRequest(FriendshipModel friendship) async {
    try {
      await _friendshipService.acceptFriendRequest(friendship.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande acceptée!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  Future<void> _rejectRequest(FriendshipModel friendship) async {
    try {
      await _friendshipService.deleteFriendship(friendship.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande refusée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  Future<void> _removeFriend(UserModel friend) async {
    final userProvider = context.read<UserProvider>();
    final currentUserId = userProvider.user?.uid;
    
    if (currentUserId == null) return;
    
    try {
      await _friendshipService.removeFriend(currentUserId, friend.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friend.firstName} retiré de vos amis')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
```

### Fichier 2: `lib/screens/friends/add_friend_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/user_service.dart';
import '../../services/friendship_service.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);
  
  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  final FriendshipService _friendshipService = FriendshipService();
  
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un ami'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par email ou nom',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
              ),
              onChanged: (value) => _searchUsers(value),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Recherchez vos amis',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    final currentUser = context.watch<UserProvider>().user;
    
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        
        // Ne pas afficher l'utilisateur actuel
        if (user.uid == currentUser?.uid) {
          return const SizedBox.shrink();
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: user.photoURL.isNotEmpty
                  ? NetworkImage(user.photoURL)
                  : null,
              child: user.photoURL.isEmpty
                  ? Text(
                      user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.email),
            trailing: FutureBuilder<String>(
              future: _getFriendshipStatus(currentUser!.uid, user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                
                final status = snapshot.data!;
                
                switch (status) {
                  case 'friends':
                    return const Chip(
                      label: Text('Amis', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    );
                  case 'pending':
                    return const Chip(
                      label: Text('En attente', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.orange,
                    );
                  default:
                    return ElevatedButton(
                      onPressed: () => _sendFriendRequest(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Ajouter'),
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      final results = await _userService.searchUsersByName(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de recherche: $e')),
      );
    }
  }
  
  Future<String> _getFriendshipStatus(String userId, String friendId) async {
    final areFriends = await _friendshipService.areFriends(userId, friendId);
    if (areFriends) return 'friends';
    
    final hasPending = await _friendshipService.hasPendingRequest(userId, friendId);
    if (hasPending) return 'pending';
    
    return 'none';
  }
  
  Future<void> _sendFriendRequest(UserModel user) async {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;
    
    try {
      await _friendshipService.sendFriendRequest(currentUser.uid, user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande envoyée à ${user.firstName}')),
      );
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
```

### Action 2.3: Connecter la navigation

Dans `lib/widgets/mini_leaderboard.dart`, remplacez les TODOs:

```dart
// Ligne 54 et 94
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FriendsScreen(),
  ),
);
```

**✅ Checkpoint:** Vous devriez pouvoir rechercher et ajouter des amis.

---

## 📋 ÉTAPE 3: PREMIERS TESTS (2 heures)

### Créer: `test/services/user_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dizonli_app/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should serialize to JSON correctly', () {
      final user = UserModel(
        uid: '123',
        email: 'test@test.com',
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'Homme',
        country: 'France',
        city: 'Paris',
        dailyGoal: 10000,
        totalSteps: 0,
        totalDistance: 0.0,
        totalCalories: 0.0,
        level: 1,
        points: 0,
        groupIds: [],
        friends: [],
        badges: [],
        photoURL: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final json = user.toJson();
      
      expect(json['uid'], '123');
      expect(json['email'], 'test@test.com');
      expect(json['firstName'], 'Test');
      expect(json['dailyGoal'], 10000);
    });
    
    test('UserModel should deserialize from JSON correctly', () {
      final json = {
        'uid': '123',
        'email': 'test@test.com',
        'firstName': 'Test',
        'lastName': 'User',
        'dateOfBirth': DateTime(1990, 1, 1).toIso8601String(),
        'gender': 'Homme',
        'country': 'France',
        'city': 'Paris',
        'dailyGoal': 10000,
        'totalSteps': 0,
        'totalDistance': 0.0,
        'totalCalories': 0.0,
        'level': 1,
        'points': 0,
        'groupIds': [],
        'friends': [],
        'badges': [],
        'photoURL': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final user = UserModel.fromJson(json);
      
      expect(user.uid, '123');
      expect(user.email, 'test@test.com');
      expect(user.firstName, 'Test');
      expect(user.dailyGoal, 10000);
    });
  });
}
```

### Lancer les tests:

```bash
flutter test test/services/user_service_test.dart
```

**✅ Checkpoint:** Le test doit passer en vert.

---

## 🎯 APRÈS CES 3 ÉTAPES

Vous aurez:
- ✅ Code propre sans duplication
- ✅ Écran friends fonctionnel
- ✅ Premier test qui passe

**Temps total:** ~6 heures de travail concentré

---

## 📞 BESOIN D'AIDE?

### Problème de compilation?
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

### Import manquant?
Vérifiez que tous les imports sont corrects en haut des fichiers.

### Erreur Firestore?
Vérifiez que Firebase est bien configuré et que les rules permettent les opérations.

---

## 🚀 SUITE DU PROGRAMME

Une fois ces 3 étapes terminées, référez-vous au **PLAN_ACTION_IMMEDIAT.md** pour continuer avec:
- Jour 3-4: Résolution TODOs
- Jour 5-7: Upload images
- Jour 8-10: Tests complets

---

**BON COURAGE! VOUS ALLEZ Y ARRIVER! 💪**

*"Le meilleur moment pour commencer, c'est maintenant."*
