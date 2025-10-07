import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/social_service.dart';
import '../services/friendship_service.dart';

/// Provider pour gérer l'état social (posts et amis)
class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();
  final FriendshipService _friendshipService = FriendshipService();

  List<PostModel> _publicPosts = [];
  List<PostModel> _friendsPosts = [];
  List<UserModel> _friends = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PostModel> get publicPosts => _publicPosts;
  List<PostModel> get friendsPosts => _friendsPosts;
  List<UserModel> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les posts publics
  void loadPublicPosts() {
    _socialService.streamPublicPosts().listen((posts) {
      _publicPosts = posts;
      notifyListeners();
    });
  }

  /// Rafraîchir le feed (force le rechargement)
  void refreshFeed() {
    loadPublicPosts();
    notifyListeners();
  }

  /// Charge les posts des amis
  void loadFriendsPosts(List<String> friendIds) {
    if (friendIds.isEmpty) {
      _friendsPosts = [];
      notifyListeners();
      return;
    }

    _socialService.streamFriendsPosts(friendIds).listen((posts) {
      _friendsPosts = posts;
      notifyListeners();
    });
  }

  /// Charge les amis d'un utilisateur
  Future<void> loadFriends(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _friends = await _friendshipService.getFriendsProfiles(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crée un nouveau post
  Future<void> createPost({
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
      await _socialService.createPost(
        userId: userId,
        userName: userName,
        userPhotoURL: userPhotoURL,
        type: type,
        content: content,
        imageUrl: imageUrl,
        data: data,
        visibility: visibility,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Toggle like sur un post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _socialService.toggleLike(postId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Ajoute un commentaire
  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    try {
      await _socialService.addComment(
        postId: postId,
        userId: userId,
        userName: userName,
        text: text,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Supprime un post
  Future<void> deletePost(String postId, String userId) async {
    try {
      await _socialService.deletePost(postId, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Envoie une demande d'ami
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await _friendshipService.sendFriendRequest(fromUserId, toUserId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Accepte une demande d'ami
  Future<void> acceptFriendRequest(String userId, String friendId) async {
    try {
      await _friendshipService.acceptFriendRequest(userId, friendId);
      await loadFriends(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refuse une demande d'ami
  Future<void> declineFriendRequest(String userId, String friendId) async {
    try {
      await _friendshipService.declineFriendRequest(userId, friendId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Supprime un ami
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await _friendshipService.removeFriend(userId, friendId);
      await loadFriends(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Recherche des utilisateurs
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      return await _friendshipService.searchUsers(query, currentUserId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

