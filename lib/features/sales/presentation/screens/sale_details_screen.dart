import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/sale.dart';
import '../../domain/models/sale_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../inventory/domain/models/product.dart';
import '../../../inventory/domain/repositories/product_repository.dart';

final saleDetailsProvider = FutureProvider.family<Sale?, String>((ref, id) {
  final repository = ref.watch(salesRepositoryProvider);
  return repository.getSaleById(id);
});

final productDetailsProvider = FutureProvider.family<Product?, String>((ref, id) {
   final repository = ref.watch(productRepositoryProvider);
   return repository.getProductById(id);
});


class SaleDetailsScreen extends ConsumerWidget {
  final String saleId;

  const SaleDetailsScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleDetailsProvider(saleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
      ),
      body: saleAsync.when(
        data: (sale) {
          if (sale == null) {
            return const Center(child: Text('Sale not found'));
          }
          return _SaleDetailsContent(sale: sale);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SaleDetailsContent extends StatelessWidget {
  final Sale sale;

  const _SaleDetailsContent({required this.sale});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildItemsTable(context),
          const SizedBox(height: 24),
          _buildSummary(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      sale.invoiceNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.paymentMethod,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, 'Date', dateFormat.format(sale.saleDate)),
                _buildInfoItem(context, 'Customer', sale.customerId ?? 'Walk-in Customer'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    if (sale.items == null || sale.items!.isEmpty) {
      return const Center(child: Text('No items in this sale'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sale.items!.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _SaleItemRow(item: sale.items![index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', currency.format(sale.totalAmount)),
            const SizedBox(height: 8),
            _buildSummaryRow('Discount', '-${currency.format(sale.discount)}'),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total',
              currency.format(sale.totalAmount - sale.discount),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

class _SaleItemRow extends ConsumerWidget {
  final SaleItem item;

  const _SaleItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(item.productId));
    
    return productAsync.when(
      data: (product) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading product'),
    );
  }
}
