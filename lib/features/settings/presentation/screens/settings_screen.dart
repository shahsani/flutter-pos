import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:test_pos/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
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
                      ref.read(themeModeProvider.notifier).setTheme(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).setTheme(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (value) =>
                      ref.read(themeModeProvider.notifier).setTheme(value!),
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
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: const Text(
                'Backup Database',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Save a copy of your data to storage.'),
              onTap: () => _backupDatabase(context),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: const Text(
                'Restore Database',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Restore data from a backup file.'),
              onTap: () => _restoreDatabase(context),
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

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final dbFolder = await getDatabasesPath();
      final dbPath = p.join(dbFolder, 'pos_app.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyyMMMMdd_HHmmss').format(now);
        final fileName = 'pos_backup_$formattedDate.db';

        // 1. Prepare temp file for sharing
        final tempDir = await getTemporaryDirectory();
        final backupPath = p.join(tempDir.path, fileName);
        await dbFile.copy(backupPath);

        // 2. Try to save directly to persistent storage for convenience
        String? directSaveLocation;
        try {
          if (Platform.isAndroid) {
            // Try saving to public Downloads folder (may require permissions on some versions)
            final downloadDir = Directory('/storage/emulated/0/Download');
            if (await downloadDir.exists()) {
              final downloadPath = p.join(downloadDir.path, fileName);
              await dbFile.copy(downloadPath);
              directSaveLocation = 'Downloads folder';
            }
          } else if (Platform.isIOS) {
            // Save to Documents (accessible via Files app due to Info.plist changes)
            final documentsDir = await getApplicationDocumentsDirectory();
            final documentsPath = p.join(documentsDir.path, fileName);
            await dbFile.copy(documentsPath);
            directSaveLocation = 'Documents folder';
          }
        } catch (e) {
          // Ignore errors for direct save, fallback to Share
          debugPrint('Direct save failed: $e');
        }

        if (context.mounted && directSaveLocation != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup saved to $directSaveLocation'),
              duration: const Duration(seconds: 4),
            ),
          );
        }

        // 3. Open Share Sheet (Universal backup method)
        if (context.mounted) {
          final xFile = XFile(backupPath);
          await Share.shareXFiles(
            [xFile],
            text: 'POS Database Backup $formattedDate',
            subject: 'POS Database Backup',
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database file not found!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    try {
      // 1. Pick file
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final sourcePath = result.files.single.path!;
        final sourceFile = File(sourcePath);

        // 2. Confirm Dialog
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Database?'),
            content: const Text(
              'Warning: This will overwrite all current data with the selected backup. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          // 3. Perform Restore
          // Close existing DB connection
          await DatabaseHelper.instance.close();

          // Copy file
          final dbFolder = await getDatabasesPath();
          final dbPath = p.join(dbFolder, 'pos_app.db');
          await sourceFile.copy(dbPath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Database restored successfully. Please restart the app.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }
}
