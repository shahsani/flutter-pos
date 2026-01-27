import 'package:sqflite/sqflite.dart';
import 'package:test_pos/features/inventory/domain/models/product.dart';
import 'package:test_pos/features/inventory/domain/repositories/product_repository.dart';

import '../../../../core/database/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _dbHelper;
  final String _userId;

  ProductRepositoryImpl(this._dbHelper, this._userId);

  @override
  Future<List<Product>> getProducts() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'user_id = ?',
      whereArgs: [_userId],
      orderBy: 'updated_at DESC',
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  @override
  Stream<List<Product>> watchProducts() async* {
    // Determine a way to stream updates. For now, we'll emit the current state.
    // In a real app with Drift, this is built-in. With raw sqflite, we'd need a Trigger or Subject.
    // For simplicity, we just fetch once here, but in a complete impl we'd use a StreamController.
    // However, to make it "live", we can yield the fetch result whenever this is called.
    // NOTE: Riverpod's StreamProvider will re-execute if invalidated.
    yield await getProducts();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'products',
      where: 'barcode = ? AND user_id = ?',
      whereArgs: [barcode, _userId],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> createProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.insert(
      'products',
      product.toMap()..['user_id'] = _userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    await db.update(
      'products',
      product.toMap()..['user_id'] = _userId,
      where: 'id = ? AND user_id = ?',
      whereArgs: [product.id, _userId],
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'products',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );
  }
}
