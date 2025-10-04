import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import 'firestore_service.dart';

/// Service de gestion des posts et du fil social
class SocialService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'posts';
  final Uuid _uuid = const Uuid();

  /// Crée un nouveau post
  Future<String> createPost({
    required String userId,
    required String userName,
    String? userPhotoURL,
    required PostType type,
    required String content,
    String? imageUrl,
    Map<String, dynamic>? data,
    PostVisibility visibility = PostVisibility.public,
  }) async {
    try {
      final postId = _uuid.v4();
      final now = DateTime.now();

      final post = PostModel(
        id: postId,
        userId: userId,
        userName: userName,
        userPhotoURL: userPhotoURL,
        type: type,
        content: content,
        imageUrl: imageUrl,
        data: data,
        visibility: visibility,
        createdAt: now,
        updatedAt: now,
      );

      await _firestoreService.createDocument(_collection, postId, post.toMap());
      return postId;
    } catch (e) {
      throw Exception('Erreur lors de la création du post: $e');
    }
  }

  /// Récupère un post par son ID
  Future<PostModel?> getPost(String postId) async {
    try {
      final data = await _firestoreService.readDocument(_collection, postId);
      return data != null ? PostModel.fromMap(data, postId) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du post: $e');
    }
  }

  /// Stream de tous les posts publics (fil global)
  Stream<List<PostModel>> streamPublicPosts({int limit = 50}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      // Filter public posts in the app instead of Firestore to avoid index requirement
      final allPosts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();
      
      return allPosts.where((post) => post.visibility == PostVisibility.public).toList();
    });
  }

  /// Stream des posts d'un utilisateur
  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Stream des posts d'une liste d'amis
  Stream<List<PostModel>> streamFriendsPosts(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    // Query without visibility filter to avoid compound index requirement
    return _firestore
        .collection(_collection)
        .where('userId', whereIn: friendIds.take(10).toList()) // Firestore limit
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      // Filter by visibility in the app
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .where((post) => 
              post.visibility == PostVisibility.public || 
              post.visibility == PostVisibility.friends)
          .toList();
    });
  }

  /// Like/Unlike un post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final post = await getPost(postId);
      if (post == null) throw Exception('Post introuvable');

      if (post.likes.contains(userId)) {
        // Unlike
        await _firestore.collection(_collection).doc(postId).update({
          'likes': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Like
        await _firestore.collection(_collection).doc(postId).update({
          'likes': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erreur lors du like: $e');
    }
  }

  /// Ajoute un commentaire à un post
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    try {
      final comment = Comment(
        userId: userId,
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(_collection).doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du commentaire: $e');
    }
  }

  /// Supprime un post
  Future<void> deletePost(String postId, String userId) async {
    try {
      final post = await getPost(postId);
      if (post == null) throw Exception('Post introuvable');
      if (post.userId != userId) {
        throw Exception('Vous ne pouvez supprimer que vos propres posts');
      }

      await _firestoreService.deleteDocument(_collection, postId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du post: $e');
    }
  }

  /// Met à jour un post
  Future<void> updatePost(String postId, String userId, {
    String? content,
    String? imageUrl,
    PostVisibility? visibility,
  }) async {
    try {
      final post = await getPost(postId);
      if (post == null) throw Exception('Post introuvable');
      if (post.userId != userId) {
        throw Exception('Vous ne pouvez modifier que vos propres posts');
      }

      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (content != null) updates['content'] = content;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (visibility != null) {
        updates['visibility'] = visibility.toString().split('.').last;
      }

      await _firestoreService.updateDocument(_collection, postId, updates);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du post: $e');
    }
  }

  /// Crée un post automatique pour un achievement
  Future<void> createAchievementPost({
    required String userId,
    required String userName,
    String? userPhotoURL,
    required String achievementText,
    int? steps,
    String? badgeId,
    String? challengeId,
  }) async {
    final Map<String, dynamic> data = {};
    if (steps != null) data['steps'] = steps;
    if (badgeId != null) data['badgeId'] = badgeId;
    if (challengeId != null) data['challengeId'] = challengeId;

    await createPost(
      userId: userId,
      userName: userName,
      userPhotoURL: userPhotoURL,
      type: PostType.achievement,
      content: achievementText,
      data: data,
      visibility: PostVisibility.public,
    );
  }
}

