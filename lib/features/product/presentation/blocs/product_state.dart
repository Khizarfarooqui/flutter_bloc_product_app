import 'package:equatable/equatable.dart';

import '../../models/product.dart';

enum ProductListStatus { initial, loading, success, failure }
enum ProductFormStatus { initial, loading, success, failure }

enum ProductSortColumn { id, name, category, price, stock }

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> products;
  final String? errorMessage;
  final String searchQuery;
  final String? categoryFilter;
  final bool inStockOnly;
  final int page;
  final int total;
  final ProductSortColumn? sortColumn;
  final bool sortAscending;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter,
    this.inStockOnly = false,
    this.page = 0,
    this.total = 0,
    this.sortColumn,
    this.sortAscending = true,
  });

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    String? errorMessage,
    String? searchQuery,
    String? categoryFilter,
    bool? inStockOnly,
    int? page,
    int? total,
    ProductSortColumn? sortColumn,
    bool? sortAscending,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      page: page ?? this.page,
      total: total ?? this.total,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  List<Product> get sortedProducts {
    if (sortColumn == null) return List.from(products);
    final list = List<Product>.from(products);
    list.sort((a, b) {
      int cmp;
      switch (sortColumn!) {
        case ProductSortColumn.id:
          cmp = a.id.compareTo(b.id);
          break;
        case ProductSortColumn.name:
          cmp = a.name.compareTo(b.name);
          break;
        case ProductSortColumn.category:
          cmp = a.category.compareTo(b.category);
          break;
        case ProductSortColumn.price:
          cmp = a.price.compareTo(b.price);
          break;
        case ProductSortColumn.stock:
          cmp = a.stock.compareTo(b.stock);
          break;
      }
      return sortAscending ? cmp : -cmp;
    });
    return list;
  }

  @override
  List<Object?> get props =>
      [status, products, errorMessage, searchQuery, categoryFilter, inStockOnly, page, total, sortColumn, sortAscending];
}

class ProductDetailState extends Equatable {
  final Product? product;
  final bool loading;
  final String? errorMessage;

  const ProductDetailState({
    this.product,
    this.loading = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    Product? product,
    bool? loading,
    String? errorMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [product, loading, errorMessage];
}

class ProductFormState extends Equatable {
  final ProductFormStatus status;
  final String? errorMessage;
  final Product? savedProduct;

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.errorMessage,
    this.savedProduct,
  });

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? errorMessage,
    Product? savedProduct,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      savedProduct: savedProduct ?? this.savedProduct,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, savedProduct];
}
