import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_pos/features/inventory/data/repositories/product_repository_impl.dart';

import '../../../../core/database/database_helper.dart';
import '../models/product.dart';

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(DatabaseHelper.instance);
});

// Products List Provider
final productsProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProducts();
});

// Single Product Provider
final productProvider = FutureProvider.family<Product?, String>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Stream<List<Product>> watchProducts();
  Future<Product?> getProductById(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<Product?> getProductByBarcode(String barcode);
}
