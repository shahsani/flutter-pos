import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/product_list_screen.dart';
import '../../features/inventory/presentation/screens/add_edit_product_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
import '../../features/sales/presentation/screens/sales_history_screen.dart';
import '../../features/sales/presentation/screens/sale_details_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/customers/presentation/screens/add_edit_customer_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'sales',
            builder: (context, state) => const SalesScreen(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const SalesHistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return SaleDetailsScreen(saleId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'inventory',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return AddEditProductScreen(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'customers',
            builder: (context, state) => const CustomerListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditCustomerScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                   final id = state.pathParameters['id'];
                  return AddEditCustomerScreen(customerId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
