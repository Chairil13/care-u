class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      message: json['message'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
    };
  }
}
