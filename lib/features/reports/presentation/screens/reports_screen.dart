import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test_pos/features/reports/domain/models/report_models.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../domain/repositories/report_repository.dart';
import '../widgets/report_stat_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  // Use domain model for state
  ReportDateRange _selectedRange = ReportDateRange(
    DateTime.now().subtract(const Duration(days: 30)),
    DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(salesReportProvider(_selectedRange));
    final topItemsAsync = ref.watch(topSellingItemsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(),
            const SizedBox(height: 24),
            reportAsync.when(
              data: (report) => _buildStatsGrid(report),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 32),
            Text(
              'Top Selling Items',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            topItemsAsync.when(
              data: (items) => _buildTopItemsList(items),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error loading items: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final dateFormat = DateFormat('MMM d, y');
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '${dateFormat.format(_selectedRange.start)} - ${dateFormat.format(_selectedRange.end)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(SalesReport report) {
    final currency = NumberFormat.currency(symbol: '\$');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        ReportStatCard(
          title: 'Total Sales',
          value: currency.format(report.totalSales),
          icon: FontAwesomeIcons.dollarSign,
          color: Colors.green,
        ),
        ReportStatCard(
          title: 'Transactions',
          value: report.totalTransactions.toString(),
          icon: FontAwesomeIcons.receipt,
          color: Colors.blue,
        ),
        ReportStatCard(
          title: 'Avg. Value',
          value: currency.format(report.averageTransactionValue),
          icon: FontAwesomeIcons.chartLine,
          color: Colors.orange,
        ),
        ReportStatCard(
          title: 'Items Sold',
          value: report.totalItemsSold.toString(),
          icon: FontAwesomeIcons.boxesStacked,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTopItemsList(List<TopSellingItem> items) {
    if (items.isEmpty) return const Text('No sales data available.');

    return Card(
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${items.indexOf(item) + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${item.quantitySold} units sold'),
            trailing: Text(
              '\$${item.totalRevenue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    // Uses Material DateTimeRange
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedRange.start,
        end: _selectedRange.end,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedRange = ReportDateRange(picked.start, picked.end);
      });
    }
  }
}
