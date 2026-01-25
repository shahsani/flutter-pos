import 'package:test_pos/features/reports/domain/models/report_models.dart';
import 'package:test_pos/features/reports/domain/repositories/report_repository.dart';

import '../../../../core/database/database_helper.dart';

class ReportRepositoryImpl implements ReportRepository {
  final DatabaseHelper _dbHelper;

  ReportRepositoryImpl(this._dbHelper);

  @override
  Future<SalesReport> getSalesReport(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final startEpoch = start.millisecondsSinceEpoch;
    final endEpoch = end.millisecondsSinceEpoch;

    // Total Sales & Transactions
    final salesResult = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_transactions,
        COALESCE(SUM(total_amount), 0) as total_sales
      FROM sales 
      WHERE sale_date BETWEEN ? AND ?
    ''',
      [startEpoch, endEpoch],
    );

    // Parse results correctly
    final row = salesResult.first;
    final totalTransactions = (row['total_transactions'] as num?)?.toInt() ?? 0;
    final totalSales = (row['total_sales'] as num?)?.toDouble() ?? 0.0;

    // Total Items Sold (Need to join or sum query)
    // Complex query due to sale_date being in 'sales' table and quantity in 'sale_items'
    final itemsResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(si.quantity), 0) as total_items
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ?
    ''',
      [startEpoch, endEpoch],
    );

    final totalItemsSold =
        (itemsResult.first['total_items'] as num?)?.toInt() ?? 0;

    // Sales by Payment Method
    final paymentResult = await db.rawQuery(
      '''
      SELECT 
        payment_method,
        COALESCE(SUM(total_amount), 0) as total
      FROM sales
      WHERE sale_date BETWEEN ? AND ?
      GROUP BY payment_method
    ''',
      [startEpoch, endEpoch],
    );

    double totalCash = 0;
    double totalCard = 0;

    for (final row in paymentResult) {
      final method = row['payment_method'] as String?;
      final amount = (row['total'] as num?)?.toDouble() ?? 0.0;
      if (method == 'Cash') {
        totalCash = amount;
      } else if (method == 'Card') {
        totalCard = amount;
      }
    }

    return SalesReport(
      totalSales: totalSales,
      totalTransactions: totalTransactions,
      averageTransactionValue: totalTransactions == 0
          ? 0
          : totalSales / totalTransactions,
      totalItemsSold: totalItemsSold,
      totalCashSales: totalCash,
      totalCardSales: totalCard,
    );
  }

  @override
  Future<List<TopSellingItem>> getTopSellingItems(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final startEpoch = start.millisecondsSinceEpoch;
    final endEpoch = end.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      '''
      SELECT 
        p.id,
        p.name,
        SUM(si.quantity) as quantity_sold,
        SUM(si.subtotal) as total_revenue
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      JOIN products p ON si.product_id = p.id
      WHERE s.sale_date BETWEEN ? AND ?
      GROUP BY p.id, p.name
      ORDER BY quantity_sold DESC
      LIMIT 5
    ''',
      [startEpoch, endEpoch],
    );

    return result.map((row) {
      return TopSellingItem(
        productId: row['id'] as String,
        productName: row['name'] as String,
        quantitySold: (row['quantity_sold'] as num).toInt(),
        totalRevenue: (row['total_revenue'] as num).toDouble(),
      );
    }).toList();
  }
}
