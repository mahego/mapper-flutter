import '../../../../core/network/api_client.dart';

/// Model para vehículo/producto del catálogo
class CatalogItemModel {
  final int id;
  final String name;
  final String? description;
  final String category;
  final String brand;
  final String model;
  final int year;
  final String? imageUrl;
  final double? price;
  final String? availability;
  final Map<String, String>? specs;

  const CatalogItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.brand,
    required this.model,
    required this.year,
    this.imageUrl,
    this.price,
    this.availability,
    this.specs,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    return CatalogItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'general',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      imageUrl: json['image_url'] ?? json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      availability: json['availability'] as String?,
      specs: (json['specs'] as Map?)?.cast<String, String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'model': model,
      'year': year,
      'image_url': imageUrl,
      'price': price,
      'availability': availability,
      'specs': specs,
    };
  }
}

/// Model para resultado de búsqueda en catálogo
class CatalogSearchResultModel {
  final List<CatalogItemModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const CatalogSearchResultModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory CatalogSearchResultModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] ?? json['data'] as List? ?? [])
        .map((item) => CatalogItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    final pagination = json['pagination'] as Map? ?? {};
    
    return CatalogSearchResultModel(
      items: items,
      total: pagination['total'] as int? ?? items.length,
      page: pagination['page'] as int? ?? json['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? json['limit'] as int? ?? 10,
      totalPages: pagination['total_pages'] as int? ?? 
                 ((pagination['total'] as int? ?? items.length) / (pagination['limit'] as int? ?? 10)).ceil(),
    );
  }
}

/// Repository para búsqueda en catálogos
class CatalogsRepository {
  final ApiClient _apiClient;

  CatalogsRepository(this._apiClient);

  /// Buscar en catálogos por query
  Future<CatalogSearchResultModel> searchCatalogs({
    required String query,
    int page = 1,
    int limit = 10,
    String? category,
    String? brand,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (brand != null) 'brand': brand,
      };

      final response = await _apiClient.get(
        '/catalogs/search',
        queryParameters: params,
      );

      final data = response.data;
      if (data is Map) {
        return CatalogSearchResultModel.fromJson(Map<String, dynamic>.from(data));
      }
      
      throw Exception('Invalid catalog search response');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de un item del catálogo
  Future<CatalogItemModel> getCatalogItemDetail(int itemId) async {
    try {
      final response = await _apiClient.get('/catalogs/$itemId');
      final data = response.data;

      final itemData = data is Map ? (data['data'] ?? data) : data;
      return CatalogItemModel.fromJson(Map<String, dynamic>.from(itemData as Map));
    } catch (e) {
      rethrow;
    }
  }

  /// Búsqueda avanzada en catálogos
  Future<CatalogSearchResultModel> advancedSearch({
    String? query,
    String? category,
    String? brand,
    int? yearFrom,
    int? yearTo,
    double? priceFrom,
    double? priceTo,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (query != null) 'q': query,
        if (category != null) 'category': category,
        if (brand != null) 'brand': brand,
        if (yearFrom != null) 'year_from': yearFrom,
        if (yearTo != null) 'year_to': yearTo,
        if (priceFrom != null) 'price_from': priceFrom,
        if (priceTo != null) 'price_to': priceTo,
      };

      final response = await _apiClient.get(
        '/catalogs/advanced-search',
        queryParameters: params,
      );

      final data = response.data;
      if (data is Map) {
        return CatalogSearchResultModel.fromJson(Map<String, dynamic>.from(data));
      }
      
      throw Exception('Invalid advanced search response');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener categorías disponibles en catálogo
  Future<List<String>> getAvailableCategories() async {
    try {
      final response = await _apiClient.get('/catalogs/categories');
      final data = response.data;

      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['categories'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items.cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener marcas disponibles en catálogo
  Future<List<String>> getAvailableBrands({String? category}) async {
    try {
      final params = <String, dynamic>{
        if (category != null) 'category': category,
      };

      final response = await _apiClient.get(
        '/catalogs/brands',
        queryParameters: params,
      );

      final data = response.data;
      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['brands'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items.cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener items destacados del catálogo
  Future<List<CatalogItemModel>> getFeaturedItems({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/catalogs/featured',
        queryParameters: {'limit': limit},
      );

      final data = response.data;
      List<dynamic> items = [];
      if (data is Map) {
        items = data['data'] ?? data['items'] ?? [];
      } else if (data is List) {
        items = data;
      }

      return items
          .map((item) => CatalogItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
