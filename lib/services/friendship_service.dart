import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendship_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import 'user_service.dart';

/// Service de gestion des amitiés
class FriendshipService {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'friendships';

  /// Envoie une demande d'ami
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      if (fromUserId == toUserId) {
        throw Exception('Vous ne pouvez pas vous ajouter vous-même');
      }

      final friendshipId = FriendshipModel.generateId(fromUserId, toUserId);
      
      // Vérifie si une amitié existe déjà
      final existingFriendship = await _getFriendship(friendshipId);
      if (existingFriendship != null) {
        if (existingFriendship.status == FriendshipStatus.accepted) {
          throw Exception('Vous êtes déjà amis');
        } else if (existingFriendship.status == FriendshipStatus.pending) {
          throw Exception('Une demande d\'ami est déjà en attente');
        } else if (existingFriendship.status == FriendshipStatus.blocked) {
          throw Exception('Impossible d\'envoyer une demande d\'ami');
        }
      }

      // Crée la demande d'ami
      final friendship = FriendshipModel(
        id: friendshipId,
        userId1: fromUserId.compareTo(toUserId) < 0 ? fromUserId : toUserId,
        userId2: fromUserId.compareTo(toUserId) < 0 ? toUserId : fromUserId,
        status: FriendshipStatus.pending,
        requesterId: fromUserId,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createDocument(
        _collection,
        friendshipId,
        friendship.toMap(),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de la demande: $e');
    }
  }

  /// Accepte une demande d'ami
  Future<void> acceptFriendRequest(String userId, String friendId) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId, friendId);
      final friendship = await _getFriendship(friendshipId);

      if (friendship == null) {
        throw Exception('Demande d\'ami introuvable');
      }

      if (friendship.status != FriendshipStatus.pending) {
        throw Exception('Cette demande n\'est plus en attente');
      }

      if (friendship.requesterId == userId) {
        throw Exception('Vous ne pouvez pas accepter votre propre demande');
      }

      // Met à jour le statut
      await _firestoreService.updateDocument(_collection, friendshipId, {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Ajoute aux listes d'amis des deux utilisateurs
      await _userService.updateUser(userId, {
        'friends': FieldValue.arrayUnion([friendId]),
      });
      await _userService.updateUser(friendId, {
        'friends': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation de la demande: $e');
    }
  }

  /// Refuse/Supprime une demande d'ami
  Future<void> declineFriendRequest(String userId, String friendId) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId, friendId);
      await _firestoreService.deleteDocument(_collection, friendshipId);
    } catch (e) {
      throw Exception('Erreur lors du refus de la demande: $e');
    }
  }

  /// Supprime un ami
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId, friendId);
      
      // Supprime des listes d'amis
      await _userService.updateUser(userId, {
        'friends': FieldValue.arrayRemove([friendId]),
      });
      await _userService.updateUser(friendId, {
        'friends': FieldValue.arrayRemove([userId]),
      });

      // Supprime l'amitié
      await _firestoreService.deleteDocument(_collection, friendshipId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'ami: $e');
    }
  }

  /// Bloque un utilisateur
  Future<void> blockUser(String userId, String targetUserId) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId, targetUserId);
      
      // Supprime des listes d'amis si nécessaire
      await _userService.updateUser(userId, {
        'friends': FieldValue.arrayRemove([targetUserId]),
      });
      await _userService.updateUser(targetUserId, {
        'friends': FieldValue.arrayRemove([userId]),
      });

      // Crée ou met à jour l'amitié avec statut bloqué
      final friendship = FriendshipModel(
        id: friendshipId,
        userId1: userId.compareTo(targetUserId) < 0 ? userId : targetUserId,
        userId2: userId.compareTo(targetUserId) < 0 ? targetUserId : userId,
        status: FriendshipStatus.blocked,
        requesterId: userId,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        _collection,
        friendshipId,
        friendship.toMap(),
      );
    } catch (e) {
      throw Exception('Erreur lors du blocage: $e');
    }
  }

  /// Récupère une amitié spécifique
  Future<FriendshipModel?> _getFriendship(String friendshipId) async {
    try {
      final data = await _firestoreService.readDocument(_collection, friendshipId);
      return data != null ? FriendshipModel.fromMap(data, friendshipId) : null;
    } catch (e) {
      return null;
    }
  }

  /// Stream des demandes d'ami en attente pour un utilisateur
  Stream<List<FriendshipModel>> streamPendingRequests(String userId) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendshipModel.fromMap(doc.data(), doc.id))
          .where((friendship) =>
              (friendship.userId1 == userId || friendship.userId2 == userId) &&
              friendship.requesterId != userId)
          .toList();
    });
  }

  /// Stream des demandes envoyées par un utilisateur
  Stream<List<FriendshipModel>> streamSentRequests(String userId) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendshipModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Récupère la liste des amis d'un utilisateur avec leurs profils
  Future<List<UserModel>> getFriendsProfiles(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user == null || user.friends.isEmpty) {
        return [];
      }

      final friendsProfiles = <UserModel>[];
      for (final friendId in user.friends) {
        final friend = await _userService.getUser(friendId);
        if (friend != null) {
          friendsProfiles.add(friend);
        }
      }

      return friendsProfiles;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des amis: $e');
    }
  }

  /// Vérifie si deux utilisateurs sont amis
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId1, userId2);
      final friendship = await _getFriendship(friendshipId);
      return friendship != null && friendship.status == FriendshipStatus.accepted;
    } catch (e) {
      return false;
    }
  }

  /// Recherche des utilisateurs par nom
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  /// Récupère le profil d'un utilisateur
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      return await _userService.getUser(userId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Vérifie le statut d'amitié entre deux utilisateurs
  Future<FriendshipStatus?> checkFriendshipStatus(String userId1, String userId2) async {
    try {
      final friendshipId = FriendshipModel.generateId(userId1, userId2);
      final friendship = await _getFriendship(friendshipId);
      return friendship?.status;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du statut: $e');
    }
  }
}

