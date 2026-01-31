import '../../models/product.dart';
import '../datasources/product_remote_datasource.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({int skip = 0, int limit = 30});
  Future<Product?> getProductById(int id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getProductsByCategory(String category);
  Future<List<Product>> getProductsFiltered({
    String? query,
    String? category,
    bool? inStockOnly,
  });
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ProductRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final ProductRemoteDataSource _dataSource;

  @override
  Future<List<Product>> getProducts({int skip = 0, int limit = 30}) =>
      _dataSource.fetchProducts(skip: skip, limit: limit);

  @override
  Future<Product?> getProductById(int id) => _dataSource.fetchProductById(id);

  @override
  Future<List<Product>> searchProducts(String query) =>
      _dataSource.searchProducts(query);

  @override
  Future<List<Product>> getProductsByCategory(String category) =>
      _dataSource.filterByCategory(category);

  @override
  Future<List<Product>> getProductsFiltered({
    String? query,
    String? category,
    bool? inStockOnly,
  }) async {
    List<Product> list;
    if (query != null && query.trim().isNotEmpty) {
      list = await _dataSource.searchProducts(query);
    } else if (category != null && category.isNotEmpty) {
      list = await _dataSource.filterByCategory(category);
    } else {
      list = await _dataSource.fetchProducts();
    }
    if (inStockOnly == true) {
      list = list.where((p) => p.isInStock).toList();
    }
    return list;
  }

  @override
  Future<Product> addProduct(Product product) =>
      _dataSource.addProduct(product);

  @override
  Future<Product> updateProduct(Product product) =>
      _dataSource.updateProduct(product);

  @override
  Future<void> deleteProduct(int id) => _dataSource.deleteProduct(id);
}
