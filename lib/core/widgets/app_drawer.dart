import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  FontAwesomeIcons.shop,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Flutter POS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: FontAwesomeIcons.chartLine,
            title: 'Dashboard',
            route: '/',
          ),
          _DrawerItem(
            icon: FontAwesomeIcons.cashRegister,
            title: 'New Sale',
            route: '/sales',
          ),
          _DrawerItem(
            icon: FontAwesomeIcons.boxesStacked,
            title: 'Inventory',
            route: '/inventory',
          ),
          _DrawerItem(
            icon: FontAwesomeIcons.users,
            title: 'Customers',
            route: '/customers',
          ),
          _DrawerItem(
            icon: FontAwesomeIcons.chartPie,
            title: 'Reports',
            route: '/reports',
          ),
          const Divider(),
          _DrawerItem(
            icon: FontAwesomeIcons.gear,
            title: 'Settings',
            route: '/settings', // Needs to be implemented
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    // Simple check: exact match or starts with for some routes (except root)
    final isSelected = route == '/' 
        ? currentRoute == '/' 
        : currentRoute.startsWith(route);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        context.pop(); // Close drawer
        context.go(route);
      },
    );
  }
}
