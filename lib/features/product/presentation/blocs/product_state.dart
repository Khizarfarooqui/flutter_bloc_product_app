import 'package:equatable/equatable.dart';

import '../../models/product.dart';

enum ProductSortColumn { id, name, category, price, stock }

sealed class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

final class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

final class ProductListLoading extends ProductListState {
  final String searchQuery;
  final String? categoryFilter;
  final bool inStockOnly;
  final ProductSortColumn? sortColumn;
  final bool sortAscending;

  const ProductListLoading({
    this.searchQuery = '',
    this.categoryFilter,
    this.inStockOnly = false,
    this.sortColumn,
    this.sortAscending = true,
  });

  @override
  List<Object?> get props => [searchQuery, categoryFilter, inStockOnly, sortColumn, sortAscending];
}

final class ProductListSuccess extends ProductListState {
  final List<Product> products;
  final String searchQuery;
  final String? categoryFilter;
  final bool inStockOnly;
  final ProductSortColumn? sortColumn;
  final bool sortAscending;

  const ProductListSuccess({
    required this.products,
    this.searchQuery = '',
    this.categoryFilter,
    this.inStockOnly = false,
    this.sortColumn,
    this.sortAscending = true,
  });

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
      [products, searchQuery, categoryFilter, inStockOnly, sortColumn, sortAscending];
}

final class ProductListFailure extends ProductListState {
  final String message;
  final String searchQuery;
  final String? categoryFilter;
  final bool inStockOnly;

  const ProductListFailure({
    required this.message,
    this.searchQuery = '',
    this.categoryFilter,
    this.inStockOnly = false,
  });

  @override
  List<Object?> get props => [message, searchQuery, categoryFilter, inStockOnly];
}

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

final class ProductDetailSuccess extends ProductDetailState {
  final Product product;

  const ProductDetailSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

final class ProductDetailFailure extends ProductDetailState {
  final String message;

  const ProductDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

sealed class ProductFormState extends Equatable {
  const ProductFormState();

  @override
  List<Object?> get props => [];
}

final class ProductFormInitial extends ProductFormState {
  const ProductFormInitial();
}

final class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

final class ProductFormSuccess extends ProductFormState {
  final Product savedProduct;

  const ProductFormSuccess(this.savedProduct);

  @override
  List<Object?> get props => [savedProduct];
}

final class ProductFormFailure extends ProductFormState {
  final String message;

  const ProductFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

extension ProductListStateFilters on ProductListState {
  String get searchQuery => switch (this) {
        ProductListLoading s => s.searchQuery,
        ProductListSuccess s => s.searchQuery,
        ProductListFailure s => s.searchQuery,
        _ => '',
      };
  String? get categoryFilter => switch (this) {
        ProductListLoading s => s.categoryFilter,
        ProductListSuccess s => s.categoryFilter,
        ProductListFailure s => s.categoryFilter,
        _ => null,
      };
  bool get inStockOnly => switch (this) {
        ProductListLoading s => s.inStockOnly,
        ProductListSuccess s => s.inStockOnly,
        ProductListFailure s => s.inStockOnly,
        _ => false,
      };
}
