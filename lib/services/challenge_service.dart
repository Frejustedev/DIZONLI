import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge_model.dart';
import 'firestore_service.dart';

/// Service for managing challenges in Firestore
class ChallengeService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collection = 'challenges';

  /// Create a new challenge
  Future<void> createChallenge(ChallengeModel challenge) {
    // Generate unique ID if not provided
    final challengeId = challenge.id.isEmpty
        ? FirebaseFirestore.instance.collection(_collection).doc().id
        : challenge.id;
    
    final challengeData = challenge.toJson();
    challengeData['id'] = challengeId;
    
    return _firestoreService.setDocument(_collection, challengeId, challengeData);
  }

  /// Get challenge by ID
  Stream<ChallengeModel?> streamChallenge(String challengeId) {
    return _firestoreService.streamDocument(_collection, challengeId).map((snapshot) {
      if (snapshot.exists) {
        return ChallengeModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get all active challenges
  Stream<List<ChallengeModel>> streamActiveChallenges() {
    final now = Timestamp.now();
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get all challenges a user is participating in
  Stream<List<ChallengeModel>> streamUserChallenges(String userId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get challenges by group
  Stream<List<ChallengeModel>> streamGroupChallenges(String groupId) {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get public challenges
  Stream<List<ChallengeModel>> streamPublicChallenges() {
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .where('scope', isEqualTo: 'global')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId, String userId) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(challengeId)
        .update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'progress.$userId': 0, // Initialize progress
    });
  }

  /// Leave a challenge
  Future<void> leaveChallenge(String challengeId, String userId) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(challengeId)
        .update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'progress.$userId': FieldValue.delete(),
    });
  }

  /// Update user progress in a challenge
  Future<void> updateProgress(
    String challengeId,
    String userId,
    int progress,
  ) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(challengeId)
        .update({
      'progress.$userId': progress,
    });
  }

  /// Increment user progress in a challenge
  Future<void> incrementProgress(
    String challengeId,
    String userId,
    int increment,
  ) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(challengeId)
        .update({
      'progress.$userId': FieldValue.increment(increment),
    });
  }

  /// Update challenge details
  Future<void> updateChallenge(
    String challengeId,
    Map<String, dynamic> data,
  ) {
    return _firestoreService.updateDocument(_collection, challengeId, data);
  }

  /// Delete a challenge
  Future<void> deleteChallenge(String challengeId) {
    return _firestoreService.deleteDocument(_collection, challengeId);
  }

  /// Get challenge leaderboard
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId,
  ) async {
    final challengeDoc = await FirebaseFirestore.instance
        .collection(_collection)
        .doc(challengeId)
        .get();

    if (!challengeDoc.exists) return [];

    final challenge = ChallengeModel.fromJson(challengeDoc.data()!);
    
    // Create leaderboard entries
    final leaderboard = challenge.progress.entries
        .map((entry) => {
              'userId': entry.key,
              'progress': entry.value,
              'percentage': (entry.value / challenge.targetValue * 100).clamp(0, 100),
              'completed': entry.value >= challenge.targetValue,
            })
        .toList();

    // Sort by progress descending
    leaderboard.sort((a, b) => (b['progress'] as int).compareTo(a['progress'] as int));

    return leaderboard;
  }

  /// Check and complete challenges for a user based on their stats
  Future<void> checkAndUpdateChallenges(
    String userId,
    int steps,
    double distance,
    int duration,
  ) async {
    // Get all active challenges for the user
    final userChallengesSnapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('participantIds', arrayContains: userId)
        .get();

    for (final doc in userChallengesSnapshot.docs) {
      final challenge = ChallengeModel.fromJson(doc.data());
      
      // Skip if challenge is not active
      if (challenge.status != ChallengeStatus.active) continue;

      // Update progress based on challenge type
      int newProgress = challenge.progress[userId] ?? 0;
      
      switch (challenge.type) {
        case ChallengeType.steps:
          newProgress = steps;
          break;
        case ChallengeType.distance:
          newProgress = distance.toInt();
          break;
        case ChallengeType.duration:
          newProgress = duration;
          break;
        case ChallengeType.streak:
          // Streak is handled differently (daily check)
          continue;
      }

      // Update if progress changed
      if (newProgress != challenge.progress[userId]) {
        await updateProgress(challenge.id, userId, newProgress);
      }
    }
  }

  /// Get completed challenges count for a user
  Future<int> getCompletedChallengesCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('participantIds', arrayContains: userId)
        .get();

    int count = 0;
    for (final doc in snapshot.docs) {
      final challenge = ChallengeModel.fromJson(doc.data());
      if (challenge.isCompletedBy(userId)) {
        count++;
      }
    }

    return count;
  }

  /// Get upcoming challenges
  Stream<List<ChallengeModel>> streamUpcomingChallenges() {
    final now = Timestamp.now();
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('startDate', isGreaterThan: now)
        .where('isPublic', isEqualTo: true)
        .orderBy('startDate')
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get completed challenges for a user
  Stream<List<ChallengeModel>> streamCompletedChallenges(String userId) {
    final now = Timestamp.now();
    return FirebaseFirestore.instance
        .collection(_collection)
        .where('participantIds', arrayContains: userId)
        .where('endDate', isLessThan: now)
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChallengeModel.fromJson(doc.data()))
          .where((challenge) => challenge.isCompletedBy(userId))
          .toList();
    });
  }
}

