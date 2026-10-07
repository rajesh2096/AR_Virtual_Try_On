import 'dart:io';
import '../core/network/api_client.dart';
import '../models/garment_model.dart';

class GarmentService {
  static Future<List<GarmentModel>> getGarments({
    int? subcategoryId,
    String? categorySlug,
    String? search,
    String? primaryColor,
  }) async {
    final queryParams = <String, String>{};
    if (subcategoryId != null) queryParams['subcategory_id'] = subcategoryId.toString();
    if (categorySlug != null) queryParams['category_slug'] = categorySlug;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (primaryColor != null && primaryColor.isNotEmpty) queryParams['primary_color'] = primaryColor;

    String endpoint = '/garments';
    if (queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await ApiClient.get(endpoint);
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
    int? subcategoryId,
    String? brand,
    String? primaryColor,
    String? size,
    String? style,
    String? description,
    required File imageFile,
  }) async {
    final fields = <String, String>{
      'name': name,
      'category': category,
    };
    if (subcategoryId != null) fields['subcategory_id'] = subcategoryId.toString();
    if (brand != null && brand.isNotEmpty) fields['brand'] = brand;
    if (primaryColor != null && primaryColor.isNotEmpty) fields['primary_color'] = primaryColor;
    if (size != null && size.isNotEmpty) fields['size'] = size;
    if (style != null && style.isNotEmpty) fields['style'] = style;
    if (description != null && description.isNotEmpty) fields['description'] = description;

    final response = await ApiClient.uploadMultipart(
      endpoint: '/garments/upload',
      fileField: 'file',
      file: imageFile,
      fields: fields,
    );
    return GarmentModel.fromJson(response);
  }

  static Future<bool> deleteGarment(int id) async {
    final response = await ApiClient.delete('/garments/$id');
    return response != null;
  }
}
