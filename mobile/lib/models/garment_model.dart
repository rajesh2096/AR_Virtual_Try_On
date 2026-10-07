import '../core/config/app_config.dart';
import 'category_model.dart';

class GarmentModel {
  final int id;
  final int userId;
  final String name;
  final String category;
  final int? subcategoryId;
  final String? brand;
  final String? primaryColor;
  final String? size;
  final String? style;
  final String? description;
  final String imagePath;
  final String? imageUrl;
  final bool isFavorite;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubcategoryModel? subcategory;

  GarmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.subcategoryId,
    this.brand,
    this.primaryColor,
    this.size,
    this.style,
    this.description,
    required this.imagePath,
    this.imageUrl,
    this.isFavorite = false,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
    this.subcategory,
  });

  GarmentModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? category,
    int? subcategoryId,
    String? brand,
    String? primaryColor,
    String? size,
    String? style,
    String? description,
    String? imagePath,
    String? imageUrl,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubcategoryModel? subcategory,
  }) {
    return GarmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      brand: brand ?? this.brand,
      primaryColor: primaryColor ?? this.primaryColor,
      size: size ?? this.size,
      style: style ?? this.style,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subcategory: subcategory ?? this.subcategory,
    );
  }

  factory GarmentModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl = json['image_url'];
    final path = json['image_path'] ?? '';
    if (imgUrl == null || imgUrl.isEmpty) {
      if (path.isNotEmpty) {
        imgUrl = '${AppConfig.baseUrl}/$path';
      }
    }

    SubcategoryModel? sub;
    if (json['subcategory'] != null && json['subcategory'] is Map<String, dynamic>) {
      sub = SubcategoryModel.fromJson(json['subcategory']);
    }

    return GarmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? 'general',
      subcategoryId: json['subcategory_id'] != null
          ? (json['subcategory_id'] is int ? json['subcategory_id'] : int.tryParse(json['subcategory_id'].toString()))
          : null,
      brand: json['brand'],
      primaryColor: json['primary_color'],
      size: json['size'],
      style: json['style'],
      description: json['description'],
      imagePath: path,
      imageUrl: imgUrl,
      isFavorite: json['is_favorite'] ?? false,
      isArchived: json['is_archived'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      subcategory: sub,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'subcategory_id': subcategoryId,
      'brand': brand,
      'primary_color': primaryColor,
      'size': size,
      'style': style,
      'description': description,
      'image_path': imagePath,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'subcategory': subcategory?.toJson(),
    };
  }
}
