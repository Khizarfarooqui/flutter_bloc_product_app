import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';
import '../widgets/product_form_modal.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailCubit>(
      create: (_) => sl<ProductDetailCubit>()..loadProduct(productId),
      child: _ProductDetailsContent(productId: productId),
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  const _ProductDetailsContent({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          BlocBuilder<ProductDetailCubit, ProductDetailState>(
            builder: (context, state) {
              if (state is! ProductDetailSuccess) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _openEditModal(context, state.product),
                tooltip: 'Edit',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          switch (state) {
            case ProductDetailInitial():
            case ProductDetailLoading():
              return const Center(child: CircularProgressIndicator());
            case ProductDetailFailure(:final message):
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<ProductDetailCubit>().loadProduct(productId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ProductDetailSuccess(:final product):
              return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.thumbnail!,
                            width: 280,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(theme),
                          ),
                        ),
                      if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                        const SizedBox(width: 32),
                      Expanded(child: _DetailsCard(product: product)),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.thumbnail!,
                            width: 280,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(theme),
                          ),
                        ),
                      ),
                    if (product.thumbnail != null && product.thumbnail!.isNotEmpty)
                      const SizedBox(height: 24),
                    _DetailsCard(product: product),
                  ],
                );
              },
            ),
          );
          }
        },
      ),
    );
  }

  Widget _placeholderImage(ThemeData theme) {
    return Container(
      width: 280,
      height: 280,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_rounded,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _openEditModal(BuildContext context, Product p) {
    ProductFormModal.show(
      context,
      product: p,
      onSaved: () {
        context.read<ProductDetailCubit>().loadProduct(productId);
      },
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(product.category),
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                ),
                Chip(
                  label: Text(
                    product.stockStatus,
                    style: TextStyle(
                      color: product.isInStock
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                  backgroundColor: product.isInStock
                      ? colorScheme.primaryContainer.withOpacity(0.5)
                      : colorScheme.errorContainer.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Product ID', value: '${product.id}'),
            _DetailRow(label: 'Price', value: '\$${product.price.toStringAsFixed(2)}'),
            _DetailRow(label: 'Stock', value: '${product.stock}'),
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ProductFormModal.show(
                  context,
                  product: product,
                  onSaved: () => context.read<ProductDetailCubit>().loadProduct(product.id),
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text('Edit Product'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
