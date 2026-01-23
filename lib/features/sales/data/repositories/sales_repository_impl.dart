import 'package:sqflite/sqflite.dart';
import 'package:test_pos/features/sales/domain/models/sale.dart';
import 'package:test_pos/features/sales/domain/models/sale_item.dart';
import 'package:test_pos/features/sales/domain/repositories/sales_repository.dart';

import '../../../../core/database/database_helper.dart';

class SalesRepositoryImpl implements SalesRepository {
  final DatabaseHelper _dbHelper;

  SalesRepositoryImpl(this._dbHelper);

  @override
  Future<void> createSale(Sale sale, List<SaleItem> items) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // 1. Insert Sale
      await txn.insert('sales', sale.toMap());

      // 2. Insert Items
      for (final item in items) {
        await txn.insert('sale_items', item.toMap());

        // 3. Update Stock (Simple decrement for now)
        // In a real app we'd also log to 'stock_transactions'
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
    });
  }

  @override
  Future<List<Sale>> getSales() async {
    final db = await _dbHelper.database;
    final result = await db.query('sales', orderBy: 'sale_date DESC');
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  @override
  Future<Sale?> getSaleById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('sales', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final sale = Sale.fromMap(result.first);
      final items = await getSaleItems(id);
      return sale.copyWith(items: items);
    }
    return null;
  }

  @override
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return result.map((map) => SaleItem.fromMap(map)).toList();
  }

  @override
  Future<String> generateInvoiceNumber() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sales');
    final count = Sqflite.firstIntValue(result) ?? 0;
    // Simple format: INV-000001
    return 'INV-${(count + 1).toString().padLeft(6, '0')}';
  }
}
