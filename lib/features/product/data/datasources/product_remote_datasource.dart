import 'package:dio/dio.dart';

import '../../models/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> fetchProducts({int skip = 0, int limit = 30});
  Future<Product?> fetchProductById(int id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> filterByCategory(String category);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;
  static const String _path = '/products';

  @override
  Future<List<Product>> fetchProducts({int skip = 0, int limit = 30}) async {
    final response = await _dio.get(
      _path,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>? ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product?> fetchProductById(int id) async {
    try {
      final response = await _dio.get('$_path/$id');
      final data = response.data as Map<String, dynamic>;
      return Product.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return fetchProducts();
    final response = await _dio.get(
      '$_path/search',
      queryParameters: {'q': query},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>? ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Product>> filterByCategory(String category) async {
    if (category.isEmpty) return fetchProducts();
    final response = await _dio.get('$_path/category/$category');
    final data = response.data as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>? ?? [];
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> addProduct(Product product) async {
    final response = await _dio.post(_path, data: product.toJson());
    final data = response.data as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final response = await _dio.put('$_path/${product.id}', data: product.toJson());
    final data = response.data as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _dio.delete('$_path/$id');
  }
}
