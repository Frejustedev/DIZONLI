import 'package:cloud_firestore/cloud_firestore.dart';

/// Type de post
enum PostType {
  achievement,
  badge,
  challenge,
  custom,
}

/// Visibilité du post
enum PostVisibility {
  public,
  friends,
  private,
}

/// Commentaire sur un post
class Comment {
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Modèle de post pour le fil social
class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoURL;
  final PostType type;
  final String content;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final List<String> likes;
  final int likeCount;
  final List<Comment> comments;
  final int commentCount;
  final PostVisibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoURL,
    required this.type,
    required this.content,
    this.imageUrl,
    this.data,
    this.likes = const [],
    this.likeCount = 0,
    this.comments = const [],
    this.commentCount = 0,
    this.visibility = PostVisibility.public,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoURL: map['userPhotoURL'],
      type: _parsePostType(map['type']),
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      data: map['data'] as Map<String, dynamic>?,
      likes: List<String>.from(map['likes'] ?? []),
      likeCount: map['likeCount'] ?? 0,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((c) => Comment.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      commentCount: map['commentCount'] ?? 0,
      visibility: _parseVisibility(map['visibility']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'type': type.toString().split('.').last,
      'content': content,
      'imageUrl': imageUrl,
      'data': data,
      'likes': likes,
      'likeCount': likeCount,
      'comments': comments.map((c) => c.toMap()).toList(),
      'commentCount': commentCount,
      'visibility': visibility.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static PostType _parsePostType(dynamic type) {
    if (type == null) return PostType.custom;
    
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'achievement':
        return PostType.achievement;
      case 'badge':
        return PostType.badge;
      case 'challenge':
        return PostType.challenge;
      default:
        return PostType.custom;
    }
  }

  static PostVisibility _parseVisibility(dynamic visibility) {
    if (visibility == null) return PostVisibility.public;
    
    final visibilityStr = visibility.toString().toLowerCase();
    switch (visibilityStr) {
      case 'friends':
        return PostVisibility.friends;
      case 'private':
        return PostVisibility.private;
      default:
        return PostVisibility.public;
    }
  }

  bool isLikedBy(String userId) => likes.contains(userId);

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoURL,
    PostType? type,
    String? content,
    String? imageUrl,
    Map<String, dynamic>? data,
    List<String>? likes,
    int? likeCount,
    List<Comment>? comments,
    int? commentCount,
    PostVisibility? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoURL: userPhotoURL ?? this.userPhotoURL,
      type: type ?? this.type,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      likes: likes ?? this.likes,
      likeCount: likeCount ?? this.likeCount,
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

