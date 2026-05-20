class MotorcycleModel {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final String plateNumber;
  final int? year;
  final DateTime? createdAt;

  MotorcycleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    this.year,
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
    };
    return map;
  }
}
