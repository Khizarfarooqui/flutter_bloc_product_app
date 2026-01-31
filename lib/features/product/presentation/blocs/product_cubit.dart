import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/product_repository_impl.dart';
import '../../models/product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductListState> {
  ProductCubit() : super(const ProductListState());

  final ProductRepositoryImpl _repo = ProductRepositoryImpl();
  static const int _pageSize = 20;

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.status == ProductListStatus.loading && !refresh) return;
    emit(state.copyWith(
      status: ProductListStatus.loading,
      page: refresh ? 0 : state.page,
      errorMessage: null,
    ));
    try {
      final list = await _repo.getProductsFiltered(
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
        category: state.categoryFilter,
        inStockOnly: state.inStockOnly ? true : null,
      );
      emit(state.copyWith(
        status: ProductListStatus.success,
        products: list,
        total: list.length,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    loadProducts(refresh: true);
  }

  void setCategoryFilter(String? category) {
    emit(state.copyWith(categoryFilter: category));
    loadProducts(refresh: true);
  }

  void setInStockOnly(bool value) {
    emit(state.copyWith(inStockOnly: value));
    loadProducts(refresh: true);
  }

  void clearFilters() {
    emit(state.copyWith(
      searchQuery: '',
      categoryFilter: null,
      inStockOnly: false,
    ));
    loadProducts(refresh: true);
  }

  void setSort(ProductSortColumn? column, {bool? ascending}) {
    if (column == null) {
      emit(state.copyWith(sortColumn: null, sortAscending: true));
      return;
    }
    final sameColumn = state.sortColumn == column;
    emit(state.copyWith(
      sortColumn: column,
      sortAscending: ascending ?? (sameColumn ? !state.sortAscending : true),
    ));
  }

  Future<List<String>> getCategories() async {
    try {
      final list = await _repo.getProducts();
      final categories =
          list.map((p) => p.category).toSet().toList()..sort();
      return categories;
    } catch (_) {
      return [];
    }
  }
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailState());

  final ProductRepositoryImpl _repo = ProductRepositoryImpl();

  Future<void> loadProduct(int id) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final product = await _repo.getProductById(id);
      emit(state.copyWith(product: product, loading: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void clear() {
    emit(const ProductDetailState());
  }
}

class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit() : super(const ProductFormState());

  final ProductRepositoryImpl _repo = ProductRepositoryImpl();

  Future<void> addProduct(Product product) async {
    emit(state.copyWith(status: ProductFormStatus.loading, errorMessage: null));
    try {
      final saved = await _repo.addProduct(product);
      emit(state.copyWith(
        status: ProductFormStatus.success,
        savedProduct: saved,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProduct(Product product) async {
    emit(state.copyWith(status: ProductFormStatus.loading, errorMessage: null));
    try {
      final saved = await _repo.updateProduct(product);
      emit(state.copyWith(
        status: ProductFormStatus.success,
        savedProduct: saved,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const ProductFormState());
  }
}
