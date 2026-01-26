import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/models/category_model.dart'; // Unused if not used directly, but usually good.
import '../controllers/category_providers.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .getProductById(widget.productId!);
      if (product != null) {
        _nameController.text = product.name;
        _skuController.text = product.sku ?? '';
        _barcodeController.text = product.barcode ?? '';
        _costPriceController.text = product.costPrice.toString();
        _sellingPriceController.text = product.sellingPrice.toString();
        _stockController.text = product.stockQuantity.toString();
        _stockController.text = product.stockQuantity.toString();
        _minStockController.text = product.minStockLevel.toString();
        _descriptionController.text = product.description ?? '';
        _selectedCategoryId = product.categoryId;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Basic Information'),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(labelText: 'SKU'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Barcode',
                            suffixIcon: Icon(Icons.qr_code_scanner),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Dropdown
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(categoryListProvider);
                      return categoriesAsync.when(
                        data: (categories) {
                          return DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No Category'),
                              ),
                              ...categories.map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                          );
                        },
                        loading: () => const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, stack) =>
                            Text('Error loading categories: $err'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Pricing & Inventory'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cost Price *',
                          ),
                          validator: (value) => _validateNumber(value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _sellingPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Selling Price *',
                          ),
                          validator: (value) => _validateNumber(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock Quantity *',
                          ),
                          validator: (value) =>
                              _validateNumber(value, isInt: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _minStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Stock Level',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Additional Details'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(
                        widget.productId == null
                            ? 'Create Product'
                            : 'Update Product',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String? _validateNumber(String? value, {bool isInt = false}) {
    if (value == null || value.isEmpty) return 'Required';
    final number = isInt ? int.tryParse(value) : double.tryParse(value);
    if (number == null) return 'Invalid number';
    if (number < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.productId ?? const Uuid().v4(),
        name: _nameController.text,
        sku: _skuController.text.isEmpty ? null : _skuController.text,
        barcode: _barcodeController.text.isEmpty
            ? null
            : _barcodeController.text,
        categoryId: _selectedCategoryId,
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        stockQuantity: int.parse(_stockController.text),
        minStockLevel: int.tryParse(_minStockController.text) ?? 0,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt:
            DateTime.now(), // In edit, we might want to keep original createdAt
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(productRepositoryProvider);
      if (widget.productId == null) {
        await repository.createProduct(product);
      } else {
        await repository.updateProduct(product);
      }

      if (mounted) {
        ref.refresh(productsProvider); // Refresh list
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
