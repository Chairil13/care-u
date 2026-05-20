class FormChecklistModel {
  final String id;
  final String teknisiId;
  final String judul;
  final String? deskripsi;
  final DateTime? createdAt;
  final List<ChecklistItemModel> items;

  FormChecklistModel({
    required this.id,
    required this.teknisiId,
    required this.judul,
    this.deskripsi,
    this.createdAt,
    this.items = const [],
  });

  factory FormChecklistModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <ChecklistItemModel>[];
    if (json['checklist_items'] != null && json['checklist_items'] is List) {
      itemsList = (json['checklist_items'] as List)
          .map((item) => ChecklistItemModel.fromJson(item))
          .toList();
    }

    return FormChecklistModel(
      id: json['id'] as String,
      teknisiId: json['teknisi_id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teknisi_id': teknisiId,
      'judul': judul,
      'deskripsi': deskripsi,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'teknisi_id': teknisiId,
      'judul': judul,
      'deskripsi': deskripsi,
    };
  }
}

class ChecklistItemModel {
  final String id;
  final String formId;
  final String itemName;

  ChecklistItemModel({
    required this.id,
    required this.formId,
    required this.itemName,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] as String,
      formId: json['form_id'] as String,
      itemName: json['item_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_id': formId,
      'item_name': itemName,
    };
  }
}

class ChecklistResultModel {
  final String id;
  final String userId;
  final String formId;
  final Map<String, dynamic> jawaban; // Map of item name to answer status/notes
  final String? feedback;
  final DateTime? createdAt;

  // Joined fields
  final String? userName;
  final String? formJudul;

  ChecklistResultModel({
    required this.id,
    required this.userId,
    required this.formId,
    required this.jawaban,
    this.feedback,
    this.createdAt,
    this.userName,
    this.formJudul,
  });

  factory ChecklistResultModel.fromJson(Map<String, dynamic> json) {
    String? userName;
    if (json['users'] != null && json['users'] is Map) {
      userName = json['users']['name'] as String?;
    }

    String? formJudul;
    if (json['form_checklist'] != null && json['form_checklist'] is Map) {
      formJudul = json['form_checklist']['judul'] as String?;
    }

    return ChecklistResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      formId: json['form_id'] as String,
      jawaban: json['jawaban'] != null ? Map<String, dynamic>.from(json['jawaban'] as Map) : {},
      feedback: json['feedback'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userName: userName,
      formJudul: formJudul,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'form_id': formId,
      'jawaban': jawaban,
      'feedback': feedback,
    };
  }
}
