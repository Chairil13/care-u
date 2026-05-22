class MotorcycleModel {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final String plateNumber;
  final int? year;
  final String? imageUrl;
  final DateTime? createdAt;

  MotorcycleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    this.year,
    this.imageUrl,
    this.createdAt,
  });

  factory MotorcycleModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      plateNumber: json['plate_number'] as String,
      year: json['year'] as int?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'year': year,
      'image_url': imageUrl,
    };
  }

  // To map for Supabase upsert/insert (without id if new)
  Map<String, dynamic> toSupabase() {
    final map = {
      'user_id': userId,
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'year': year,
      'image_url': imageUrl,
    };
    return map;
  }

  MotorcycleModel copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    String? plateNumber,
    int? year,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return MotorcycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      year: year ?? this.year,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
