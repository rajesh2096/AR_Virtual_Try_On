import 'dart:io';
import '../core/network/api_client.dart';
import '../models/tryon_session_model.dart';

class TryonService {
  /// Create a try-on session using a selected Model Vault profile ID and Garment ID
  static Future<TryonSessionModel> createSessionWithModel({
    required int garmentId,
    required int personProfileId,
    int? outfitId,
  }) async {
    final fields = <String, String>{
      'garment_id': garmentId.toString(),
      'person_profile_id': personProfileId.toString(),
    };
    if (outfitId != null) fields['outfit_id'] = outfitId.toString();

    final response = await ApiClient.uploadMultipart(
      endpoint: '/tryon/create',
      fields: fields,
    );
    return TryonSessionModel.fromJson(response);
  }

  /// Create a try-on session uploading an ad-hoc person image file directly
  static Future<TryonSessionModel> createSessionWithImage({
    required int garmentId,
    required File personImage,
  }) async {
    final response = await ApiClient.uploadMultipart(
      endpoint: '/tryon/create',
      fileField: 'person_image',
      file: personImage,
      fields: {
        'garment_id': garmentId.toString(),
      },
    );
    return TryonSessionModel.fromJson(response);
  }

  /// Retrieve complete history of user's try-on sessions
  static Future<List<TryonSessionModel>> getHistory() async {
    final response = await ApiClient.get('/tryon/history');
    if (response is List) {
      return response.map((item) => TryonSessionModel.fromJson(item)).toList();
    }
    return [];
  }

  /// Retrieve detailed information for a specific session
  static Future<TryonSessionModel> getSessionById(int id) async {
    final response = await ApiClient.get('/tryon/$id');
    return TryonSessionModel.fromJson(response);
  }
}
