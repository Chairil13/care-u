class CommentModel {
  final String id;
  final String storyId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? parentId;

  // Joined user details
  final String? userName;
  final String? userAvatarUrl;

  CommentModel({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.userName,
    this.userAvatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? avatarUrl;
    if (json['users'] != null && json['users'] is Map) {
      name = json['users']['name'] as String?;
      avatarUrl = json['users']['avatar_url'] as String?;
    }

    return CommentModel(
      id: json['id'] as String,
      storyId: json['story_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      parentId: json['parent_id'] as String?,
      userName: name,
      userAvatarUrl: avatarUrl,
    );
  }
}
