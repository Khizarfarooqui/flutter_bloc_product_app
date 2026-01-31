import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/product.dart';
import '../blocs/product_cubit.dart';
import '../blocs/product_state.dart';

class ProductFormModal extends StatelessWidget {
  const ProductFormModal({
    super.key,
    this.product,
    required this.onSaved,
  });

  final Product? product;
  final VoidCallback onSaved;

  static Future<void> show(
    BuildContext context, {
    Product? product,
    required VoidCallback onSaved,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (_) => ProductFormCubit(),
        child: ProductFormModal(product: product, onSaved: onSaved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = product != null;
    return BlocConsumer<ProductFormCubit, ProductFormState>(
      listener: (context, state) {
        if (state.status == ProductFormStatus.success) {
          Navigator.of(context).pop();
          onSaved();
        }
        if (state.status == ProductFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return _ProductFormDialog(
          product: product,
          isLoading: state.status == ProductFormStatus.loading,
          onSave: (p) {
            if (isEdit) {
              context.read<ProductFormCubit>().updateProduct(p);
            } else {
              context.read<ProductFormCubit>().addProduct(p);
            }
          },
        );
      },
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({
    this.product,
    required this.isLoading,
    required this.onSave,
  });

  final Product? product;
  final bool isLoading;
  final void Function(Product) onSave;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.product != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. beauty, electronics',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: '0.00',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Price is required';
                    }
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    hintText: '0',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Stock is required';
                    }
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return 'Enter a valid stock';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Product description',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  if (!_formKey.currentState!.validate()) return;
                  final id = widget.product?.id ?? 0;
                  final product = Product(
                    id: id,
                    name: _nameController.text.trim(),
                    category: _categoryController.text.trim(),
                    price: double.tryParse(_priceController.text) ?? 0,
                    stock: int.tryParse(_stockController.text) ?? 0,
                    description: _descriptionController.text.trim().isEmpty
                        ? null
                        : _descriptionController.text.trim(),
                    thumbnail: widget.product?.thumbnail,
                  );
                  widget.onSave(product);
                },
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
