class MonitoringModel {
  final String id;
  final String userId;
  final String teknisiId;
  final String? motorcycleId;
  final String? catatan;
  final String? rekomendasi;
  final String status; // 'baik', 'perlu_perhatian', 'kritis'
  final DateTime? createdAt;

  // Joined fields (optional, from query joins)
  final String? userName;
  final String? motorcycleName;

  MonitoringModel({
    required this.id,
    required this.userId,
    required this.teknisiId,
    this.motorcycleId,
    this.catatan,
    this.rekomendasi,
    this.status = 'baik',
    this.createdAt,
    this.userName,
    this.motorcycleName,
  });

  factory MonitoringModel.fromJson(Map<String, dynamic> json) {
    // Handle joined user data
    String? userName;
    if (json['users'] != null && json['users'] is Map) {
      userName = json['users']['name'] as String?;
    }

    // Handle joined motorcycle data
    String? motorcycleName;
    if (json['motorcycles'] != null && json['motorcycles'] is Map) {
      final m = json['motorcycles'];
      motorcycleName = '${m['brand'] ?? ''} ${m['model'] ?? ''}'.trim();
    }

    return MonitoringModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      teknisiId: json['teknisi_id'] as String,
      motorcycleId: json['motorcycle_id'] as String?,
      catatan: json['catatan'] as String?,
      rekomendasi: json['rekomendasi'] as String?,
      status: json['status'] as String? ?? 'baik',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userName: userName,
      motorcycleName: motorcycleName,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'teknisi_id': teknisiId,
      'motorcycle_id': motorcycleId,
      'catatan': catatan,
      'rekomendasi': rekomendasi,
      'status': status,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'baik':
        return 'Baik';
      case 'perlu_perhatian':
        return 'Perlu Perhatian';
      case 'kritis':
        return 'Kritis';
      default:
        return status;
    }
  }
}
