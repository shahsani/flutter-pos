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

  // Helper method to determine device type and layout parameters
  _ReportsLayoutParams _getLayoutParams(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Determine if tablet based on shortest side (works for both orientations)
    final shortestSide = size.shortestSide;
    final isTablet = shortestSide >= 600;
    final isLandscape = orientation == Orientation.landscape;

    return _ReportsLayoutParams(
      isTablet: isTablet,
      isLandscape: isLandscape,
      screenWidth: size.width,
      // Stats grid columns - 4 for tablet/landscape, 2 for mobile portrait
      statsGridColumns: isTablet ? 4 : (isLandscape ? 4 : 2),
      // Padding adapts to screen size
      horizontalPadding: isTablet ? 24.0 : 16.0,
      // Child aspect ratio for stats grid
      statsAspectRatio: isTablet
          ? (isLandscape ? 1.8 : 1.5)
          : (isLandscape ? 2.0 : 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(salesReportProvider(_selectedRange));
    final topItemsAsync = ref.watch(topSellingItemsProvider(_selectedRange));

    return Scaffold(
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layoutParams = _getLayoutParams(context);

          return SingleChildScrollView(
            padding: EdgeInsets.all(layoutParams.horizontalPadding),
            child: layoutParams.isLandscape
                ? _buildLandscapeLayout(
                    reportAsync,
                    topItemsAsync,
                    layoutParams,
                  )
                : _buildPortraitLayout(
                    reportAsync,
                    topItemsAsync,
                    layoutParams,
                  ),
          );
        },
      ),
    );
  }

  /// Portrait layout - vertical stacking
  Widget _buildPortraitLayout(
    AsyncValue<SalesReport> reportAsync,
    AsyncValue<List<TopSellingItem>> topItemsAsync,
    _ReportsLayoutParams layoutParams,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(layoutParams),
        const SizedBox(height: 24),
        reportAsync.when(
          data: (report) => _buildStatsGrid(report, layoutParams),
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
          data: (items) => _buildTopItemsList(items, layoutParams),
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => Text('Error loading items: $e'),
        ),
      ],
    );
  }

  /// Landscape layout - side by side arrangement
  Widget _buildLandscapeLayout(
    AsyncValue<SalesReport> reportAsync,
    AsyncValue<List<TopSellingItem>> topItemsAsync,
    _ReportsLayoutParams layoutParams,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(layoutParams),
        const SizedBox(height: 24),
        // Stats grid - full width at top
        reportAsync.when(
          data: (report) => _buildStatsGrid(report, layoutParams),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
        const SizedBox(height: 24),
        // Top selling items in a row layout for landscape on tablets
        if (layoutParams.isTablet) ...[
          Text(
            'Top Selling Items',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          topItemsAsync.when(
            data: (items) => _buildTopItemsGrid(items, layoutParams),
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error loading items: $e'),
          ),
        ] else ...[
          // Side by side for mobile landscape
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Selling Items',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    topItemsAsync.when(
                      data: (items) => _buildTopItemsList(items, layoutParams),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error loading items: $e'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateHeader(_ReportsLayoutParams layoutParams) {
    final dateFormat = DateFormat('MMM d, y');
    final iconSize = layoutParams.isTablet ? 18.0 : 16.0;

    return Row(
      children: [
        Icon(Icons.calendar_today, size: iconSize, color: Colors.grey),
        SizedBox(width: layoutParams.isTablet ? 12 : 8),
        Text(
          '${dateFormat.format(_selectedRange.start)} - ${dateFormat.format(_selectedRange.end)}',
          style: layoutParams.isTablet
              ? Theme.of(context).textTheme.titleLarge
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    SalesReport report,
    _ReportsLayoutParams layoutParams,
  ) {
    final currency = NumberFormat.currency(symbol: '\$');
    final spacing = layoutParams.isTablet ? 20.0 : 16.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: layoutParams.statsGridColumns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: layoutParams.statsAspectRatio,
      children: [
        ReportStatCard(
          title: 'Total Sales',
          value: currency.format(report.totalSales),
          icon: FontAwesomeIcons.dollarSign,
          color: Colors.green,
          isTablet: layoutParams.isTablet,
        ),
        ReportStatCard(
          title: 'Transactions',
          value: report.totalTransactions.toString(),
          icon: FontAwesomeIcons.receipt,
          color: Colors.blue,
          isTablet: layoutParams.isTablet,
        ),
        ReportStatCard(
          title: 'Avg. Value',
          value: currency.format(report.averageTransactionValue),
          icon: FontAwesomeIcons.chartLine,
          color: Colors.orange,
          isTablet: layoutParams.isTablet,
        ),
        ReportStatCard(
          title: 'Items Sold',
          value: report.totalItemsSold.toString(),
          icon: FontAwesomeIcons.boxesStacked,
          color: Colors.purple,
          isTablet: layoutParams.isTablet,
        ),
      ],
    );
  }

  Widget _buildTopItemsList(
    List<TopSellingItem> items,
    _ReportsLayoutParams layoutParams,
  ) {
    if (items.isEmpty) return const Text('No sales data available.');

    return Card(
      child: Column(
        children: items.map((item) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: layoutParams.isTablet ? 20 : 16,
              vertical: layoutParams.isTablet ? 4 : 0,
            ),
            leading: CircleAvatar(
              radius: layoutParams.isTablet ? 22 : 20,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${items.indexOf(item) + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: layoutParams.isTablet ? 16 : 14,
                ),
              ),
            ),
            title: Text(
              item.productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: layoutParams.isTablet ? 16 : 14,
              ),
            ),
            subtitle: Text(
              '${item.quantitySold} units sold',
              style: TextStyle(fontSize: layoutParams.isTablet ? 14 : 12),
            ),
            trailing: Text(
              '\$${item.totalRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: layoutParams.isTablet ? 16 : 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Grid layout for top items - used on tablet landscape
  Widget _buildTopItemsGrid(
    List<TopSellingItem> items,
    _ReportsLayoutParams layoutParams,
  ) {
    if (items.isEmpty) return const Text('No sales data available.');

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layoutParams.isTablet ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.quantitySold} units • \$${item.totalRevenue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

/// Layout parameters for responsive Reports UI
class _ReportsLayoutParams {
  final bool isTablet;
  final bool isLandscape;
  final double screenWidth;
  final int statsGridColumns;
  final double horizontalPadding;
  final double statsAspectRatio;

  const _ReportsLayoutParams({
    required this.isTablet,
    required this.isLandscape,
    required this.screenWidth,
    required this.statsGridColumns,
    required this.horizontalPadding,
    required this.statsAspectRatio,
  });
}
