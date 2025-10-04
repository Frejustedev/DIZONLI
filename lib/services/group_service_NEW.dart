import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import 'firestore_service.dart';
import 'dart:math';

/// Service for managing groups in Firestore
class GroupService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'groups';

  /// Create a new group and save to Firestore
  Future<void> createGroup(GroupModel group) {
    // Generate unique ID if not provided
    final groupId = group.id.isEmpty
        ? FirebaseFirestore.instance.collection(_collection).doc().id
        : group.id;
    
    final groupData = group.toJson();
    groupData['id'] = groupId;
    
    return _firestoreService.setDocument(_collection, groupId, groupData);
  }

  /// Get group by ID
  Stream<GroupModel?> streamGroup(String groupId) {
    return _firestoreService.streamDocument(_collection, groupId).map((snapshot) {
      if (snapshot.exists) {
        return GroupModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get all groups a user is a member of
  Stream<List<GroupModel>> streamUserGroups(String userId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Join a group using an invite code
  Future<void> joinGroupByInviteCode(String userId, String inviteCode) async {
    // Search for group with this invite code
    final querySnapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Groupe introuvable avec ce code');
    }

    final groupDoc = querySnapshot.docs.first;
    final groupData = groupDoc.data();
    final memberIds = List<String>.from(groupData['memberIds'] ?? []);

    // Check if user is already a member
    if (memberIds.contains(userId)) {
      throw Exception('Vous êtes déjà membre de ce groupe');
    }

    // Add user to members list
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(groupDoc.id)
        .update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Add a member to a group
  Future<void> addGroupMember(String groupId, String userId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });
  }

  /// Remove a member from a group
  Future<void> removeGroupMember(String groupId, String userId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  /// Update group details
  Future<void> updateGroup(String groupId, Map<String, dynamic> data) {
    return _firestoreService.updateDocument(_collection, groupId, data);
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) {
    return _firestoreService.deleteDocument(_collection, groupId);
  }

  /// Generate a random invite code
  String generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Search public groups
  Stream<List<GroupModel>> searchPublicGroups({String? query}) {
    Query<Map<String, dynamic>> queryRef = FirebaseFirestore.instance
        .collection(_collection)
        .where('isPrivate', isEqualTo: false);

    if (query != null && query.isNotEmpty) {
      queryRef = queryRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff');
    }

    return queryRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupModel.fromJson(doc.data()))
          .toList();
    });
  }
}

