import 'dart:io';
import '../core/network/api_client.dart';
import '../models/garment_model.dart';

class GarmentService {
  static Future<List<GarmentModel>> getGarments() async {
    final response = await ApiClient.get('/garments');
    if (response is List) {
      return response.map((item) => GarmentModel.fromJson(item)).toList();
    }
    return [];
  }

  static Future<GarmentModel> getGarmentById(int id) async {
    final response = await ApiClient.get('/garments/$id');
    return GarmentModel.fromJson(response);
  }

  static Future<GarmentModel> uploadGarment({
    required String name,
    required String category,
    required File imageFile,
  }) async {
    final response = await ApiClient.uploadMultipart(
      endpoint: '/garments/upload',
      fileField: 'file',
      file: imageFile,
      fields: {
        'name': name,
        'category': category,
      },
    );
    return GarmentModel.fromJson(response);
  }

  static Future<bool> deleteGarment(int id) async {
    final response = await ApiClient.delete('/garments/$id');
    return response != null;
  }
}
