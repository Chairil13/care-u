import 'dart:convert';

class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;

  // Joined user details
  final String? userName;
  final String? userAvatarUrl;
  final String? userRole;

  // Check if this story is actually a post (mediaUrl is stored as a JSON array starting with '[')
  bool get isPost => mediaUrl.startsWith('[');

  // Check if this story is a video Reel
  bool get isReel => mediaUrl.contains('/reels/');

  // Get parsed list of image URLs from the JSON array, or fallback to single URL list
  List<String> get postImages {
    if (!isPost) return [mediaUrl];
    try {
      final List<dynamic> decoded = json.decode(mediaUrl);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [mediaUrl];
    }
  }

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.caption,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
    this.userRole,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? avatarUrl;
    String? role;
    if (json['users'] != null && json['users'] is Map) {
      name = json['users']['name'] as String?;
      avatarUrl = json['users']['avatar_url'] as String?;
      role = json['users']['role'] as String?;
    }

    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      caption: json['caption'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      userName: name,
      userAvatarUrl: avatarUrl,
      userRole: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
