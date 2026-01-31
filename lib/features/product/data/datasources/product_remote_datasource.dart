import 'dart:convert';

import 'package:http/http.dart' as http;

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
  static const String _baseUrl = 'https://dummyjson.com/products';

  final http.Client client = http.Client();

  @override
  Future<List<Product>> fetchProducts({int skip = 0, int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl?skip=$skip&limit=$limit');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>? ?? [];
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  @override
  Future<Product?> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Product.fromJson(data);
    }
    if (response.statusCode == 404) return null;
    throw Exception('Failed to load product: ${response.statusCode}');
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) return fetchProducts();
    final uri = Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>? ?? [];
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to search: ${response.statusCode}');
  }

  @override
  Future<List<Product>> filterByCategory(String category) async {
    if (category.isEmpty) return fetchProducts();
    final uri = Uri.parse('$_baseUrl/category/${Uri.encodeComponent(category)}');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>? ?? [];
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to filter: ${response.statusCode}');
  }

  @override
  Future<Product> addProduct(Product product) async {
    final uri = Uri.parse('$_baseUrl/add');
    final body = json.encode(product.toJson());
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Product.fromJson(data);
    }
    throw Exception('Failed to add product: ${response.statusCode}');
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final uri = Uri.parse('$_baseUrl/${product.id}');
    final body = json.encode(product.toJson());
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Product.fromJson(data);
    }
    throw Exception('Failed to update product: ${response.statusCode}');
  }

  @override
  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await client.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}
