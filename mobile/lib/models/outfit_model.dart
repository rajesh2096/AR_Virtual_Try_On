import 'garment_model.dart';

class OutfitItemModel {
  final int id;
  final int outfitId;
  final int garmentId;
  final String slotType;
  final int sortOrder;
  final DateTime? createdAt;
  final GarmentModel? garment;

  OutfitItemModel({
    required this.id,
    required this.outfitId,
    required this.garmentId,
    required this.slotType,
    this.sortOrder = 0,
    this.createdAt,
    this.garment,
  });

  factory OutfitItemModel.fromJson(Map<String, dynamic> json) {
    GarmentModel? g;
    if (json['garment'] != null && json['garment'] is Map<String, dynamic>) {
      g = GarmentModel.fromJson(json['garment']);
    }

    return OutfitItemModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      outfitId: json['outfit_id'] is int ? json['outfit_id'] : int.parse(json['outfit_id'].toString()),
      garmentId: json['garment_id'] is int ? json['garment_id'] : int.parse(json['garment_id'].toString()),
      slotType: json['slot_type'] ?? 'upper',
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      garment: g,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfit_id': outfitId,
      'garment_id': garmentId,
      'slot_type': slotType,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'garment': garment?.toJson(),
    };
  }
}

class OutfitModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OutfitItemModel> items;

  OutfitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  OutfitModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OutfitItemModel>? items,
  }) {
    return OutfitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    List<OutfitItemModel> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => OutfitItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OutfitModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      isFavorite: json['is_favorite'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
