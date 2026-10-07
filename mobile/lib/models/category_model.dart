class SubcategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String layerType;
  final int sortOrder;
  final bool isActive;

  SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.layerType,
    required this.sortOrder,
    required this.isActive,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      layerType: json['layer_type'] ?? 'upper',
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'layer_type': layerType,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String superType;
  final String? iconName;
  final int sortOrder;
  final bool isActive;
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.superType,
    this.iconName,
    required this.sortOrder,
    required this.isActive,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<SubcategoryModel> subs = [];
    if (json['subcategories'] != null && json['subcategories'] is List) {
      subs = (json['subcategories'] as List)
          .map((item) => SubcategoryModel.fromJson(item))
          .toList();
    }
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      superType: json['super_type'] ?? 'clothing',
      iconName: json['icon_name'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      subcategories: subs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'super_type': superType,
      'icon_name': iconName,
      'sort_order': sortOrder,
      'is_active': isActive,
      'subcategories': subcategories.map((s) => s.toJson()).toList(),
    };
  }
}
