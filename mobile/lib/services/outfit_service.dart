import '../core/network/api_client.dart';
import '../models/outfit_model.dart';

class OutfitService {
  /// Fetch all outfits for current authenticated user
  static Future<List<OutfitModel>> getOutfits() async {
    final response = await ApiClient.get('/outfits');
    if (response is List) {
      return response.map((item) => OutfitModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Fetch single outfit by ID with detailed items
  static Future<OutfitModel> getOutfitById(int id) async {
    final response = await ApiClient.get('/outfits/$id');
    return OutfitModel.fromJson(response as Map<String, dynamic>);
  }

  /// Create a new outfit with title, optional description, and garment items
  static Future<OutfitModel> createOutfit({
    required String title,
    String? description,
    bool isFavorite = false,
    List<Map<String, dynamic>> items = const [],
  }) async {
    final response = await ApiClient.post(
      '/outfits/create',
      body: {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        'is_favorite': isFavorite,
        'items': items,
      },
    );
    return OutfitModel.fromJson(response as Map<String, dynamic>);
  }

  /// Update an existing outfit's title, description, or items
  static Future<OutfitModel> updateOutfit({
    required int id,
    String? title,
    String? description,
    bool? isFavorite,
    List<Map<String, dynamic>>? items,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (isFavorite != null) body['is_favorite'] = isFavorite;
    if (items != null) body['items'] = items;

    final response = await ApiClient.put('/outfits/$id', body: body);
    return OutfitModel.fromJson(response as Map<String, dynamic>);
  }

  /// Delete an outfit by ID
  static Future<bool> deleteOutfit(int id) async {
    final response = await ApiClient.delete('/outfits/$id');
    return response != null;
  }
}
