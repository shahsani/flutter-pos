import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:test_pos/core/widgets/app_drawer.dart';
import 'widgets/expandable_fab.dart';
import '../../reports/domain/repositories/report_repository.dart';
import '../../reports/domain/models/report_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isFabOpen = false;

  void _toggleFab(bool isOpen) {
    setState(() {
      _isFabOpen = isOpen;
    });
  }

  void _closeFab() {
    if (_isFabOpen) {
      setState(() {
        _isFabOpen = false;
      });
    }
  }

  // Helper method to determine device type and layout parameters
  _LayoutParams _getLayoutParams(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final width = size.width;

    // Determine if tablet based on shortest side (works for both orientations)
    final shortestSide = size.shortestSide;
    final isTablet = shortestSide >= 600;
    final isLandscape = orientation == Orientation.landscape;

    return _LayoutParams(
      isTablet: isTablet,
      isLandscape: isLandscape,
      screenWidth: width,
      // Quick actions grid columns
      quickActionsColumns: isTablet
          ? (isLandscape ? 6 : 4)
          : (isLandscape ? 4 : 3),
      // Chart height adapts to orientation
      chartHeight: isLandscape ? 180.0 : 200.0,
      // Padding adapts to screen size
      horizontalPadding: isTablet ? 24.0 : 16.0,
      // Stats cards per row
      statsCardsPerRow: isTablet || isLandscape ? 4 : 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get today's date range
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayRange = ReportDateRange(startOfDay, endOfDay);

    final todayStatsAsync = ref.watch(salesReportProvider(todayRange));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _closeFab,
        behavior: HitTestBehavior.translucent,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(salesReportProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layoutParams = _getLayoutParams(context);

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(layoutParams.horizontalPadding),
                child: layoutParams.isLandscape
                    ? _buildLandscapeLayout(
                        context,
                        todayStatsAsync,
                        layoutParams,
                      )
                    : _buildPortraitLayout(
                        context,
                        todayStatsAsync,
                        layoutParams,
                      ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: ExpandableFab(
        isOpen: _isFabOpen,
        onOpenChanged: _toggleFab,
        icon: const Icon(Icons.add),
        activeIcon: const Icon(Icons.close),
        actions: [
          ExpandableFabAction(
            icon: FontAwesomeIcons.cashRegister,
            label: 'New Sale',
            color: Colors.blue,
            onPressed: () => context.go('/sales'),
          ),
          ExpandableFabAction(
            icon: FontAwesomeIcons.userPlus,
            label: 'New Customer',
            color: Colors.teal,
            onPressed: () => context.go('/customers/add'),
          ),
          ExpandableFabAction(
            icon: FontAwesomeIcons.clockRotateLeft,
            label: 'View Sales',
            color: Colors.indigo,
            onPressed: () => context.go('/sales/history'),
          ),
          ExpandableFabAction(
            icon: FontAwesomeIcons.layerGroup,
            label: 'Categories',
            color: Colors.deepPurple,
            onPressed: () => context.go('/categories'),
          ),
        ],
      ),
    );
  }

  /// Portrait layout - vertical stacking
  Widget _buildPortraitLayout(
    BuildContext context,
    AsyncValue<SalesReport> todayStatsAsync,
    _LayoutParams layoutParams,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats section
        todayStatsAsync.when(
          data: (stats) => _buildQuickStats(context, stats, layoutParams),
          loading: () => _buildQuickStatsLoading(context, layoutParams),
          error: (e, s) => _buildQuickStatsError(context, layoutParams),
        ),
        const SizedBox(height: 24),

        // Quick Actions section
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuickActionsGrid(context, layoutParams),

        const SizedBox(height: 32),

        // Chart section
        Text(
          'Sales by Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        todayStatsAsync.when(
          data: (stats) => _buildSalesPieChart(context, stats, layoutParams),
          loading: () => SizedBox(
            height: layoutParams.chartHeight,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  /// Landscape layout - side by side arrangement for better space utilization
  Widget _buildLandscapeLayout(
    BuildContext context,
    AsyncValue<SalesReport> todayStatsAsync,
    _LayoutParams layoutParams,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats section - full width at top
        todayStatsAsync.when(
          data: (stats) => _buildQuickStats(context, stats, layoutParams),
          loading: () => _buildQuickStatsLoading(context, layoutParams),
          error: (e, s) => _buildQuickStatsError(context, layoutParams),
        ),
        const SizedBox(height: 24),

        // Side-by-side: Quick Actions and Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions (left side)
            Expanded(
              flex: layoutParams.isTablet ? 3 : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context, layoutParams),
                ],
              ),
            ),

            SizedBox(width: layoutParams.horizontalPadding),

            // Chart (right side)
            Expanded(
              flex: layoutParams.isTablet ? 2 : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales by Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  todayStatsAsync.when(
                    data: (stats) =>
                        _buildSalesPieChart(context, stats, layoutParams),
                    loading: () => SizedBox(
                      height: layoutParams.chartHeight,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  /// Build Quick Actions Grid with responsive columns
  Widget _buildQuickActionsGrid(
    BuildContext context,
    _LayoutParams layoutParams,
  ) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _buildActionItem(
            context,
            title: 'Categories',
            icon: FontAwesomeIcons.layerGroup,
            color: Colors.blueAccent,
            onTap: () => context.go('/categories'),
          ),
          _buildActionItem(
            context,
            title: 'Inventory',
            icon: FontAwesomeIcons.boxesStacked,
            color: Colors.orange,
            onTap: () => context.go('/inventory'),
          ),
          _buildActionItem(
            context,
            title: 'Customers',
            icon: FontAwesomeIcons.users,
            color: Colors.teal,
            onTap: () => context.go('/customers'),
          ),

          _buildActionItem(
            context,
            title: 'Sales',
            icon: FontAwesomeIcons.clockRotateLeft,
            color: Colors.indigo,
            onTap: () => context.go('/sales/history'),
          ),
          _buildActionItem(
            context,
            title: 'Reports',
            icon: FontAwesomeIcons.chartPie,
            color: Colors.purple,
            onTap: () => context.go('/reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: _DashboardCard(
        title: title,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    SalesReport stats,
    _LayoutParams layoutParams,
  ) {
    final currency = NumberFormat.currency(symbol: '\$');
    final spacing = layoutParams.isTablet ? 20.0 : 16.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: currency.format(stats.totalSales),
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
            isTablet: layoutParams.isTablet,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: stats.totalTransactions.toString(),
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
            isTablet: layoutParams.isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsLoading(
    BuildContext context,
    _LayoutParams layoutParams,
  ) {
    final spacing = layoutParams.isTablet ? 20.0 : 16.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: '...',
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
            isTablet: layoutParams.isTablet,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: '...',
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
            isTablet: layoutParams.isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsError(
    BuildContext context,
    _LayoutParams layoutParams,
  ) {
    final spacing = layoutParams.isTablet ? 20.0 : 16.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: '\$0.00',
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
            isTablet: layoutParams.isTablet,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: '0',
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
            isTablet: layoutParams.isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesPieChart(
    BuildContext context,
    SalesReport stats,
    _LayoutParams layoutParams,
  ) {
    if (stats.totalSales == 0) {
      return Container(
        height: layoutParams.chartHeight,
        alignment: Alignment.center,
        child: Text(
          'No sales today',
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      );
    }

    final double cashPercentage = stats.totalSales > 0
        ? (stats.totalCashSales / stats.totalSales) * 100
        : 0;
    final double cardPercentage = stats.totalSales > 0
        ? (stats.totalCardSales / stats.totalSales) * 100
        : 0;

    // In landscape mode, use a more compact layout
    final isCompactChart = layoutParams.isLandscape && !layoutParams.isTablet;
    final chartRadius = isCompactChart ? 40.0 : 50.0;
    final centerRadius = isCompactChart ? 30.0 : 40.0;

    return SizedBox(
      height: layoutParams.chartHeight,
      child: layoutParams.isLandscape
          ? Column(
              // Vertical layout for landscape - chart on top, legend below
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: centerRadius,
                      sections: [
                        if (stats.totalCashSales > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: stats.totalCashSales,
                            title: '${cashPercentage.toStringAsFixed(1)}%',
                            radius: chartRadius,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (stats.totalCardSales > 0)
                          PieChartSectionData(
                            color: Colors.blue,
                            value: stats.totalCardSales,
                            title: '${cardPercentage.toStringAsFixed(1)}%',
                            radius: chartRadius,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ChartLegend(
                      color: Colors.green,
                      label: 'Cash',
                      value: NumberFormat.currency(
                        symbol: '\$',
                      ).format(stats.totalCashSales),
                      compact: true,
                    ),
                    const SizedBox(width: 16),
                    _ChartLegend(
                      color: Colors.blue,
                      label: 'Card',
                      value: NumberFormat.currency(
                        symbol: '\$',
                      ).format(stats.totalCardSales),
                      compact: true,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (stats.totalCashSales > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: stats.totalCashSales,
                            title: '${cashPercentage.toStringAsFixed(1)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (stats.totalCardSales > 0)
                          PieChartSectionData(
                            color: Colors.blue,
                            value: stats.totalCardSales,
                            title: '${cardPercentage.toStringAsFixed(1)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChartLegend(
                      color: Colors.green,
                      label: 'Cash',
                      value: NumberFormat.currency(
                        symbol: '\$',
                      ).format(stats.totalCashSales),
                    ),
                    const SizedBox(height: 12),
                    _ChartLegend(
                      color: Colors.blue,
                      label: 'Card',
                      value: NumberFormat.currency(
                        symbol: '\$',
                      ).format(stats.totalCardSales),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
} // End of _DashboardScreenState

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool compact;

  const _ChartLegend({
    required this.color,
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? 20.0 : 16.0;
    final iconSize = isTablet ? 20.0 : 16.0;
    final valueStyle = isTablet
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(icon, size: iconSize, color: color),
              ],
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Layout parameters for responsive UI
class _LayoutParams {
  final bool isTablet;
  final bool isLandscape;
  final double screenWidth;
  final int quickActionsColumns;
  final double chartHeight;
  final double horizontalPadding;
  final int statsCardsPerRow;

  const _LayoutParams({
    required this.isTablet,
    required this.isLandscape,
    required this.screenWidth,
    required this.quickActionsColumns,
    required this.chartHeight,
    required this.horizontalPadding,
    required this.statsCardsPerRow,
  });
}
