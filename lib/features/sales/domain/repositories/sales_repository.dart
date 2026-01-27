import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_pos/features/sales/data/repositories/sales_repository_impl.dart';

import '../../../../core/database/database_helper.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

// Repository Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Repository Provider
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  return SalesRepositoryImpl(DatabaseHelper.instance, userId);
});

abstract class SalesRepository {
  Future<void> createSale(Sale sale, List<SaleItem> items);
  Future<List<Sale>> getSales();
  Future<Sale?> getSaleById(String id);
  Future<List<SaleItem>> getSaleItems(String saleId);
  Future<String> generateInvoiceNumber();
}
