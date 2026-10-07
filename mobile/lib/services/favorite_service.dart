import '../core/network/api_client.dart';
import '../models/garment_model.dart';

class FavoriteService {
  static Future<List<GarmentModel>> getFavorites() async {
    final response = await ApiClient.get('/favorites');
    if (response is List) {
      final List<GarmentModel> garments = [];
      for (final item in response) {
        if (item is Map<String, dynamic> && item['garment'] != null) {
          garments.add(GarmentModel.fromJson(item['garment']));
        }
      }
      return garments;
    }
    return [];
  }

  static Future<bool> addFavorite(int garmentId) async {
    final response = await ApiClient.post('/favorites/$garmentId');
    return response != null;
  }

  static Future<bool> removeFavorite(int garmentId) async {
    final response = await ApiClient.delete('/favorites/$garmentId');
    return response != null;
  }

  static Future<bool> toggleFavorite(int garmentId, bool isCurrentlyFavorite) async {
    if (isCurrentlyFavorite) {
      return !(await removeFavorite(garmentId));
    } else {
      return await addFavorite(garmentId);
    }
  }
}
