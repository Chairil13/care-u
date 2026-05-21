class StoryModel {
  final String id;
  final String userId;
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;

  // Joined user details
  final String? userName;
  final String? userAvatarUrl;

  StoryModel({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.caption,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? avatarUrl;
    if (json['users'] != null && json['users'] is Map) {
      name = json['users']['name'] as String?;
      avatarUrl = json['users']['avatar_url'] as String?;
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
