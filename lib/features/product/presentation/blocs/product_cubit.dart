import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/product_repository_impl.dart';
import '../../models/product.dart';
import 'product_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit({required ProductRepositoryImpl repository})
      : _repo = repository,
        super(const ProductListInitial());

  final ProductRepositoryImpl _repo;

  Future<void> loadProducts({bool refresh = false}) async {
    final current = state;
    if (current is ProductListLoading && !refresh) return;
    final searchQuery = current is ProductListSuccess || current is ProductListFailure
        ? (current.searchQuery)
        : (current is ProductListLoading ? current.searchQuery : '');
    final categoryFilter = current is ProductListSuccess || current is ProductListFailure
        ? (current.categoryFilter)
        : (current is ProductListLoading ? current.categoryFilter : null);
    final inStockOnly = current is ProductListSuccess || current is ProductListFailure
        ? (current.inStockOnly)
        : (current is ProductListLoading ? current.inStockOnly : false);
    final sortColumn = current is ProductListSuccess
        ? current.sortColumn
        : (current is ProductListLoading ? current.sortColumn : null);
    final sortAscending = current is ProductListSuccess
        ? current.sortAscending
        : (current is ProductListLoading ? current.sortAscending : true);

    emit(ProductListLoading(
      searchQuery: searchQuery,
      categoryFilter: categoryFilter,
      inStockOnly: inStockOnly,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
    ));
    try {
      final list = await _repo.getProductsFiltered(
        query: searchQuery.isEmpty ? null : searchQuery,
        category: categoryFilter,
        inStockOnly: inStockOnly ? true : null,
      );
      emit(ProductListSuccess(
        products: list,
        searchQuery: searchQuery,
        categoryFilter: categoryFilter,
        inStockOnly: inStockOnly,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
      ));
    } catch (e) {
      emit(ProductListFailure(
        message: e.toString(),
        searchQuery: searchQuery,
        categoryFilter: categoryFilter,
        inStockOnly: inStockOnly,
      ));
    }
  }

  void setSearchQuery(String query) {
    final current = state;
    if (current is ProductListSuccess) {
      emit(current.copyWith(searchQuery: query));
    } else if (current is ProductListFailure) {
      emit(ProductListLoading(
        searchQuery: query,
        categoryFilter: current.categoryFilter,
        inStockOnly: current.inStockOnly,
      ));
    } else {
      emit(ProductListLoading(searchQuery: query));
    }
    loadProducts(refresh: true);
  }

  void setCategoryFilter(String? category) {
    final current = state;
    if (current is ProductListSuccess) {
      emit(current.copyWith(categoryFilter: category));
    } else if (current is ProductListFailure) {
      emit(ProductListLoading(
        searchQuery: current.searchQuery,
        categoryFilter: category,
        inStockOnly: current.inStockOnly,
      ));
    } else if (current is ProductListLoading) {
      emit(current.copyWith(categoryFilter: category));
    } else {
      emit(ProductListLoading(categoryFilter: category));
    }
    loadProducts(refresh: true);
  }

  void setInStockOnly(bool value) {
    final current = state;
    if (current is ProductListSuccess) {
      emit(current.copyWith(inStockOnly: value));
    } else if (current is ProductListFailure) {
      emit(ProductListLoading(
        searchQuery: current.searchQuery,
        categoryFilter: current.categoryFilter,
        inStockOnly: value,
      ));
    } else if (current is ProductListLoading) {
      emit(current.copyWith(inStockOnly: value));
    } else {
      emit(ProductListLoading(inStockOnly: value));
    }
    loadProducts(refresh: true);
  }

  void clearFilters() {
    emit(const ProductListLoading());
    loadProducts(refresh: true);
  }

  void setSort(ProductSortColumn? column, {bool? ascending}) {
    final current = state;
    if (current is! ProductListSuccess) return;
    final sameColumn = current.sortColumn == column;
    emit(current.copyWith(
      sortColumn: column,
      sortAscending: ascending ?? (sameColumn ? !current.sortAscending : true),
    ));
  }

  Future<List<String>> getCategories() async {
    try {
      final list = await _repo.getProducts();
      return list.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
    } catch (_) {
      return [];
    }
  }
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required ProductRepositoryImpl repository})
      : _repo = repository,
        super(const ProductDetailInitial());

  final ProductRepositoryImpl _repo;

  Future<void> loadProduct(int id) async {
    emit(const ProductDetailLoading());
    try {
      final product = await _repo.getProductById(id);
      if (product != null) {
        emit(ProductDetailSuccess(product));
      } else {
        emit(const ProductDetailFailure('Product not found'));
      }
    } catch (e) {
      emit(ProductDetailFailure(e.toString()));
    }
  }

  void clear() {
    emit(const ProductDetailInitial());
  }
}

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({required ProductRepositoryImpl repository})
      : _repo = repository,
        super(const ProductFormInitial());

  final ProductRepositoryImpl _repo;

  Future<void> addProduct(Product product) async {
    emit(const ProductFormLoading());
    try {
      final saved = await _repo.addProduct(product);
      emit(ProductFormSuccess(saved));
    } catch (e) {
      emit(ProductFormFailure(e.toString()));
    }
  }

  Future<void> updateProduct(Product product) async {
    emit(const ProductFormLoading());
    try {
      final saved = await _repo.updateProduct(product);
      emit(ProductFormSuccess(saved));
    } catch (e) {
      emit(ProductFormFailure(e.toString()));
    }
  }

  void reset() {
    emit(const ProductFormInitial());
  }
}

extension _ProductListSuccessCopy on ProductListSuccess {
  ProductListSuccess copyWith({
    String? searchQuery,
    String? categoryFilter,
    bool? inStockOnly,
    ProductSortColumn? sortColumn,
    bool? sortAscending,
  }) {
    return ProductListSuccess(
      products: products,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

extension _ProductListLoadingCopy on ProductListLoading {
  ProductListLoading copyWith({
    String? searchQuery,
    String? categoryFilter,
    bool? inStockOnly,
    ProductSortColumn? sortColumn,
    bool? sortAscending,
  }) {
    return ProductListLoading(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}
