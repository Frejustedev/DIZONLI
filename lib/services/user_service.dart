import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Service de gestion des utilisateurs dans Firestore
class UserService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'users';

  /// Crée un profil utilisateur dans Firestore après inscription
  Future<void> createUser(UserModel user) async {
    try {
      await _firestoreService.createDocument(
        _collection,
        user.uid,
        user.toJson(),
      );
    } catch (e) {
      throw Exception('Erreur lors de la création du profil utilisateur: $e');
    }
  }

  /// Récupère un utilisateur par son UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final data = await _firestoreService.readDocument(_collection, uid);
      return data != null ? UserModel.fromJson(data) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  /// Met à jour les informations de l'utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestoreService.updateDocument(_collection, uid, data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  /// Met à jour la photo de profil
  Future<void> updatePhotoURL(String uid, String photoURL) async {
    await updateUser(uid, {'photoURL': photoURL});
  }

  /// Met à jour l'objectif quotidien
  Future<void> updateDailyGoal(String uid, int goal) async {
    await updateUser(uid, {'dailyGoal': goal});
  }

  /// Stream pour écouter les changements d'un utilisateur
  Stream<UserModel?> streamUser(String uid) {
    return _firestore.collection(_collection).doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Attribue un badge à un utilisateur
  Future<void> awardBadge(String userId, String badgeId) {
    return updateUser(userId, {
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  /// Met à jour les statistiques totales
  Future<void> updateTotalStats(String uid, {
    int? steps,
    double? distance,
    double? calories,
  }) async {
    final Map<String, dynamic> updates = {};
    
    if (steps != null) {
      updates['totalSteps'] = FieldValue.increment(steps);
    }
    if (distance != null) {
      updates['totalDistance'] = FieldValue.increment(distance);
    }
    if (calories != null) {
      updates['totalCalories'] = FieldValue.increment(calories);
    }
    
    if (updates.isNotEmpty) {
      updates['lastActive'] = FieldValue.serverTimestamp();
      await updateUser(uid, updates);
    }
  }

  /// Ajoute un badge à l'utilisateur
  Future<void> addBadge(String uid, String badgeId) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'badges': FieldValue.arrayUnion([badgeId]),
        'points': FieldValue.increment(10), // Points pour badge
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du badge: $e');
    }
  }

  /// Ajoute un ami
  Future<void> addFriend(String uid, String friendUid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'friends': FieldValue.arrayUnion([friendUid]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'ami: $e');
    }
  }

  /// Supprime un ami
  Future<void> removeFriend(String uid, String friendUid) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'friends': FieldValue.arrayRemove([friendUid]),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'ami: $e');
    }
  }

  /// Ajoute un groupe
  Future<void> addGroup(String uid, String groupId) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'groups': FieldValue.arrayUnion([groupId]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du groupe: $e');
    }
  }

  /// Supprime un groupe
  Future<void> removeGroup(String uid, String groupId) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression du groupe: $e');
    }
  }

  /// Met à jour les paramètres
  Future<void> updateSettings(String uid, {
    bool? notifications,
    bool? publicProfile,
    bool? shareActivity,
  }) async {
    final Map<String, dynamic> settings = {};
    
    if (notifications != null) settings['settings.notifications'] = notifications;
    if (publicProfile != null) settings['settings.publicProfile'] = publicProfile;
    if (shareActivity != null) settings['settings.shareActivity'] = shareActivity;
    
    if (settings.isNotEmpty) {
      await updateUser(uid, settings);
    }
  }

  /// Récupère les amis d'un utilisateur
  Future<List<UserModel>> getFriends(String uid) async {
    try {
      final user = await getUser(uid);
      if (user == null || user.friends.isEmpty) return [];

      final friendsDocs = await Future.wait(
        user.friends.map((friendId) => getUser(friendId)),
      );

      return friendsDocs.whereType<UserModel>().toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des amis: $e');
    }
  }

  /// Stream pour écouter les changements d'un utilisateur
  Stream<UserModel?> watchUser(String uid) {
    return _firestoreService
        .watchDocument(_collection, uid)
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Recherche des utilisateurs par email
  Future<List<UserModel>> searchUsersByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'utilisateurs: $e');
    }
  }

  /// Classement des utilisateurs par nombre de pas
  Future<List<UserModel>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('totalSteps', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération du classement: $e');
    }
  }
}

