import 'dart:io';
import '../core/network/api_client.dart';
import '../models/tryon_session_model.dart';

class TryonService {
  static Future<TryonSessionModel> createSession({
    int? garmentId,
    int? personProfileId,
    File? personImage,
    int? outfitId,
  }) async {
    final fields = <String, String>{};
    if (garmentId != null) fields['garment_id'] = garmentId.toString();
    if (personProfileId != null) fields['person_profile_id'] = personProfileId.toString();
    if (outfitId != null) fields['outfit_id'] = outfitId.toString();

    dynamic response;
    if (personImage != null) {
      response = await ApiClient.uploadMultipart(
        endpoint: '/tryon/create',
        fileField: 'person_image',
        file: personImage,
        fields: fields,
      );
    } else {
      response = await ApiClient.uploadMultipart(
        endpoint: '/tryon/create',
        fileField: '',
        file: File(''), // Handled conditionally when personProfileId is supplied
        fields: fields,
      );
    }
    return TryonSessionModel.fromJson(response);
  }

  static Future<TryonSessionModel> createSessionWithModel({
    required int garmentId,
    required int personProfileId,
  }) async {
    final response = await ApiClient.post(
      '/tryon/create',
      body: {
        'garment_id': garmentId,
        'person_profile_id': personProfileId,
      },
    );
    return TryonSessionModel.fromJson(response);
  }

  static Future<List<TryonSessionModel>> getHistory() async {
    final response = await ApiClient.get('/tryon/history');
    if (response is List) {
      return response.map((item) => TryonSessionModel.fromJson(item)).toList();
    }
    return [];
  }

  static Future<TryonSessionModel> getSessionById(int id) async {
    final response = await ApiClient.get('/tryon/$id');
    return TryonSessionModel.fromJson(response);
  }
}
