import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../widgets/app_bar_with_search.dart';
import '../widgets/product_form_modal.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit()..loadProducts(),
      child: const _ProductListContent(),
    );
  }
}

class _ProductListContent extends StatelessWidget {
  const _ProductListContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBarWithSearch(
        title: 'Products',
        onSearchChanged: (q) => context.read<ProductCubit>().setSearchQuery(q),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openAddModal(context),
            tooltip: 'Add product',
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductListState>(
        builder: (context, state) {
          if (state.status == ProductListStatus.initial ||
              state.status == ProductListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProductListStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Error loading products'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<ProductCubit>().loadProducts(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterBar(state: state),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: isWide
                      ? _ProductDataTable(state: state)
                      : _ProductGridView(products: state.sortedProducts),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddModal(BuildContext context) {
    ProductFormModal.show(
      context,
      onSaved: () => context.read<ProductCubit>().loadProducts(refresh: true),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _CategoryFilter(state: state),

            FilterChip(
              label: const Text('In stock only'),
              selected: state.inStockOnly,
              onSelected: (v) =>
                  context.read<ProductCubit>().setInStockOnly(v),
            ),

            if (state.searchQuery.isNotEmpty ||
                state.categoryFilter != null ||
                state.inStockOnly)
              TextButton.icon(
                onPressed: () =>
                    context.read<ProductCubit>().clearFilters(),
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    final set = state.products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet();
    if (state.categoryFilter != null &&
        state.categoryFilter!.isNotEmpty &&
        !set.contains(state.categoryFilter)) {
      set.add(state.categoryFilter!);
    }
    final categories = set.toList()..sort();
    if (categories.isEmpty) return const SizedBox.shrink();
    return DropdownButton<String>(
      value: state.categoryFilter,
      hint: const Text('Category'),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All categories'),
        ),
        ...categories.map(
          (c) => DropdownMenuItem(value: c, child: Text(c)),
        ),
      ],
      onChanged: (v) => context.read<ProductCubit>().setCategoryFilter(v),
    );
  }
}

class _ProductDataTable extends StatelessWidget {
  const _ProductDataTable({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = state.sortedProducts;
    final sortColumn = state.sortColumn;
    final sortAscending = state.sortAscending;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            sortColumnIndex: sortColumn != null
                ? [
                    ProductSortColumn.id,
                    ProductSortColumn.name,
                    ProductSortColumn.category,
                    ProductSortColumn.price,
                    ProductSortColumn.stock,
                  ].indexOf(sortColumn)
                : null,
            sortAscending: sortAscending,
            columns: [
              DataColumn(
                label: const Text('ID'),
                onSort: (_, __) => context.read<ProductCubit>().setSort(ProductSortColumn.id),
              ),
              DataColumn(
                label: const Text('Name'),
                onSort: (_, __) => context.read<ProductCubit>().setSort(ProductSortColumn.name),
              ),
              DataColumn(
                label: const Text('Category'),
                onSort: (_, __) => context.read<ProductCubit>().setSort(ProductSortColumn.category),
              ),
              DataColumn(
                label: const Text('Price'),
                onSort: (_, __) => context.read<ProductCubit>().setSort(ProductSortColumn.price),
              ),
              DataColumn(label: const Text('Stock status')),
              const DataColumn(label: Text('Actions')),
            ],
            rows: products.map((p) {
              return DataRow(
                cells: [
                  DataCell(Text('${p.id}')),
                  DataCell(Text(p.name)),
                  DataCell(Text(p.category)),
                  DataCell(Text('\$${p.price.toStringAsFixed(2)}')),
                  DataCell(
                    Chip(
                      label: Text(
                        p.stockStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: p.isInStock
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      backgroundColor: p.isInStock
                          ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                          : theme.colorScheme.errorContainer.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_rounded, size: 20),
                        onPressed: () => context.push('/products/${p.id}'),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: () => _openEditModal(context, p),
                        tooltip: 'Edit',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _openEditModal(BuildContext context, Product p) {
    ProductFormModal.show(
      context,
      product: p,
      onSaved: () => context.read<ProductCubit>().loadProducts(refresh: true),
    );
  }
}

class _ProductGridView extends StatelessWidget {
  const _ProductGridView({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = MediaQuery.sizeOf(context).width > 600 ? 2 : 1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/products/${p.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${p.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          p.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(
                            p.stockStatus,
                            style: TextStyle(
                              fontSize: 11,
                              color: p.isInStock
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                          ),
                          backgroundColor: p.isInStock
                              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                              : theme.colorScheme.errorContainer.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/products/${p.id}'),
                          child: const Text('View'),
                        ),
                        TextButton(
                          onPressed: () {
                            ProductFormModal.show(
                              context,
                              product: p,
                              onSaved: () => context
                                  .read<ProductCubit>()
                                  .loadProducts(refresh: true),
                            );
                          },
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
