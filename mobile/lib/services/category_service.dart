import '../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.get('/categories');
    if (response is List) {
      return response.map((item) => CategoryModel.fromJson(item)).toList();
    }
    return [];
  }

  static Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    final response = await ApiClient.get('/categories/$categoryId/subcategories');
    if (response is List) {
      return response.map((item) => SubcategoryModel.fromJson(item)).toList();
    }
    return [];
  }
}
