import '../core/config/app_config.dart';

class GarmentModel {
  final int id;
  final int userId;
  final String name;
  final String category;
  final String imagePath;
  final String? imageUrl;
  final DateTime? createdAt;

  GarmentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.imagePath,
    this.imageUrl,
    this.createdAt,
  });

  factory GarmentModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl = json['image_url'];
    final path = json['image_path'] ?? '';
    if (imgUrl == null || imgUrl.isEmpty) {
      if (path.isNotEmpty) {
        imgUrl = '${AppConfig.baseUrl}/$path';
      }
    }
    return GarmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      category: json['category'] ?? 'general',
      imagePath: path,
      imageUrl: imgUrl,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'image_path': imagePath,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
