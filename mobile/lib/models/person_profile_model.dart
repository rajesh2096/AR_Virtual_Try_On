import '../core/config/app_config.dart';

class PersonProfileModel {
  final int id;
  final int userId;
  final String title;
  final String imagePath;
  final String? imageUrl;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PersonProfileModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.imagePath,
    this.imageUrl,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  PersonProfileModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? imagePath,
    String? imageUrl,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PersonProfileModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl = json['image_url'];
    final path = json['image_path'] ?? '';
    if (imgUrl == null || imgUrl.isEmpty) {
      if (path.isNotEmpty) {
        imgUrl = '${AppConfig.baseUrl}/$path';
      }
    }

    return PersonProfileModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      title: json['title'] ?? 'Standing Model',
      imagePath: path,
      imageUrl: imgUrl,
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'image_path': imagePath,
      'image_url': imageUrl,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
