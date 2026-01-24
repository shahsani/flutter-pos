import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        behavior: HitTestBehavior.translucent, // Catch taps on empty space
        child: RefreshIndicator(
          onRefresh: () async {
            // Invalidate the provider to force a refresh
            ref.invalidate(salesReportProvider);
            // Wait a bit for the new data to load
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                todayStatsAsync.when(
                  data: (stats) => _buildQuickStats(context, stats),
                  loading: () => _buildQuickStatsLoading(context),
                  error: (e, s) => _buildQuickStatsError(context),
                ),
                const SizedBox(height: 24),
                // Wrap in GestureDetector to swallow taps on interactive elements if needed,
                // but usually the specific widget's onTap wins.
                // However, the parent GestureDetector might still receive it if child acts transparently.
                // In this case, we just want "outside FAB" to close FAB.
                // Tapping a card *performs an action*, which might be fine to also close FAB or not.
                // Since navigating away closes the screen, it doesn't matter much.
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: [
                    _DashboardCard(
                      title: 'Inventory',
                      icon: FontAwesomeIcons.boxesStacked,
                      color: Colors.orange,
                      onTap: () => context.go('/inventory'),
                    ),
                    _DashboardCard(
                      title: 'Customers',
                      icon: FontAwesomeIcons.users,
                      color: Colors.teal,
                      onTap: () => context.go('/customers'),
                    ),
                    _DashboardCard(
                      title: 'Reports',
                      icon: FontAwesomeIcons.chartPie,
                      color: Colors.purple,
                      onTap: () => context.go('/reports'),
                    ),
                  ],
                ),
                // Add extra padding at bottom to ensure scrolling doesn't hide content behind FAB
                const SizedBox(height: 100),
              ],
            ),
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
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, SalesReport stats) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: currency.format(stats.totalSales),
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: stats.totalTransactions.toString(),
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsLoading(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: '...',
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: '...',
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsError(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Today\'s Sales',
            value: '\$0.00',
            icon: FontAwesomeIcons.dollarSign,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'Transactions',
            value: '0',
            icon: FontAwesomeIcons.receipt,
            color: Colors.indigo,
          ),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
