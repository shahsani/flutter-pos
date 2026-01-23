import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/providers/theme_provider.dart';
import '../../../../core/widgets/app_drawer.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).state = value!,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).state = value!,
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).state = value!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Data Management'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Reset Database',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Clear all products, customers, and sales.'),
              onTap: () => _showResetDialog(context),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Flutter POS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text('Version 1.0.0'),
                  SizedBox(height: 4),
                  Text('Built with Flutter & Material 3'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text(
          'This action cannot be undone. All data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              // TODO: Implement actual database reset
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database reset functionality pending...'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
