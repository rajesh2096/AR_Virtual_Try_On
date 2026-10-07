import '../core/config/app_config.dart';
import 'garment_model.dart';

class TryonSessionModel {
  final int id;
  final int userId;
  final int garmentId;
  final String personImagePath;
  final String? personImageUrl;
  final String? resultImagePath;
  final String? resultImageUrl;
  final String status;
  final DateTime? createdAt;
  final GarmentModel? garment;
  final String? message;

  TryonSessionModel({
    required this.id,
    required this.userId,
    required this.garmentId,
    required this.personImagePath,
    this.personImageUrl,
    this.resultImagePath,
    this.resultImageUrl,
    required this.status,
    this.createdAt,
    this.garment,
    this.message,
  });

  factory TryonSessionModel.fromJson(Map<String, dynamic> json) {
    String? pUrl = json['person_image_url'];
    final pPath = json['person_image_path'] ?? '';
    if ((pUrl == null || pUrl.isEmpty) && pPath.isNotEmpty) {
      pUrl = '${AppConfig.baseUrl}/$pPath';
    }

    String? rUrl = json['result_image_url'];
    final rPath = json['result_image_path'] ?? '';
    if ((rUrl == null || rUrl.isEmpty) && rPath.isNotEmpty) {
      rUrl = '${AppConfig.baseUrl}/$rPath';
    }

    return TryonSessionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      garmentId: json['garment_id'] is int ? json['garment_id'] : int.parse(json['garment_id'].toString()),
      personImagePath: pPath,
      personImageUrl: pUrl,
      resultImagePath: rPath,
      resultImageUrl: rUrl,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      garment: json['garment'] != null ? GarmentModel.fromJson(json['garment']) : null,
      message: json['message'],
    );
  }
}
