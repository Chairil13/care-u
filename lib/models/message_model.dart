class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;
  final String messageType; // 'text' | 'image' | 'location'
  final double? latitude;
  final double? longitude;
  final String? locationName;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.createdAt,
    this.messageType = 'text',
    this.latitude,
    this.longitude,
    this.locationName,
  });

  bool get isLocation => messageType == 'location';
  bool get isImage => messageType == 'image' || (imageUrl != null && messageType == 'text');

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      message: json['message'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      messageType: json['message_type'] as String? ?? 'text',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['location_name'] as String?,
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
      'message_type': messageType,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
      'message_type': messageType,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }
}
