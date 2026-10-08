import '../core/config/app_config.dart';
import 'garment_model.dart';
import 'person_profile_model.dart';

class TryonResultModel {
  final int id;
  final int sessionId;
  final String resultImagePath;
  final String? resultImageUrl;
  final int? generationTimeMs;
  final DateTime? createdAt;

  TryonResultModel({
    required this.id,
    required this.sessionId,
    required this.resultImagePath,
    this.resultImageUrl,
    this.generationTimeMs,
    this.createdAt,
  });

  factory TryonResultModel.fromJson(Map<String, dynamic> json) {
    String? rUrl = json['result_image_url'];
    final rPath = json['result_image_path'] ?? '';
    if ((rUrl == null || rUrl.isEmpty) && rPath.isNotEmpty) {
      rUrl = '${AppConfig.baseUrl}/$rPath';
    }

    return TryonResultModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      sessionId: json['session_id'] is int ? json['session_id'] : int.parse(json['session_id'].toString()),
      resultImagePath: rPath,
      resultImageUrl: rUrl,
      generationTimeMs: json['generation_time_ms'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'result_image_path': resultImagePath,
      'result_image_url': resultImageUrl,
      'generation_time_ms': generationTimeMs,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class TryonSessionModel {
  final int id;
  final int userId;
  final int? garmentId;
  final int? personProfileId;
  final int? outfitId;
  final String? personImagePath;
  final String? personImageUrl;
  final String? resultImagePath;
  final String? resultImageUrl;
  final String sessionType;
  final String status;
  final String? errorMessage;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final GarmentModel? garment;
  final PersonProfileModel? personProfile;
  final List<TryonResultModel> results;

  TryonSessionModel({
    required this.id,
    required this.userId,
    this.garmentId,
    this.personProfileId,
    this.outfitId,
    this.personImagePath,
    this.personImageUrl,
    this.resultImagePath,
    this.resultImageUrl,
    this.sessionType = 'single',
    required this.status,
    this.errorMessage,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.garment,
    this.personProfile,
    this.results = const [],
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

    List<TryonResultModel> resultsList = [];
    if (json['results'] != null && json['results'] is List) {
      resultsList = (json['results'] as List)
          .map((r) => TryonResultModel.fromJson(r))
          .toList();
    }

    return TryonSessionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      garmentId: json['garment_id'] != null
          ? (json['garment_id'] is int ? json['garment_id'] : int.tryParse(json['garment_id'].toString()))
          : null,
      personProfileId: json['person_profile_id'] != null
          ? (json['person_profile_id'] is int ? json['person_profile_id'] : int.tryParse(json['person_profile_id'].toString()))
          : null,
      outfitId: json['outfit_id'] != null
          ? (json['outfit_id'] is int ? json['outfit_id'] : int.tryParse(json['outfit_id'].toString()))
          : null,
      personImagePath: pPath,
      personImageUrl: pUrl,
      resultImagePath: rPath,
      resultImageUrl: rUrl,
      sessionType: json['session_type'] ?? 'single',
      status: json['status'] ?? 'pending',
      errorMessage: json['error_message'],
      message: json['message'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      garment: json['garment'] != null ? GarmentModel.fromJson(json['garment']) : null,
      personProfile: json['person_profile'] != null ? PersonProfileModel.fromJson(json['person_profile']) : null,
      results: resultsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'garment_id': garmentId,
      'person_profile_id': personProfileId,
      'outfit_id': outfitId,
      'person_image_path': personImagePath,
      'person_image_url': personImageUrl,
      'result_image_path': resultImagePath,
      'result_image_url': resultImageUrl,
      'session_type': sessionType,
      'status': status,
      'error_message': errorMessage,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'garment': garment?.toJson(),
      'person_profile': personProfile?.toJson(),
      'results': results.map((r) => r.toJson()).toList(),
    };
  }
}
