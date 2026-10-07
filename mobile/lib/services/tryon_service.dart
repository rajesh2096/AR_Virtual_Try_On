import 'dart:io';
import '../core/network/api_client.dart';
import '../models/tryon_session_model.dart';

class TryonService {
  static Future<TryonSessionModel> createSession({
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
