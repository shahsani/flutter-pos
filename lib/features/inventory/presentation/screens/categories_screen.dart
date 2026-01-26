import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_pos/core/constants/app_colors.dart';
import 'package:test_pos/features/inventory/domain/models/category_model.dart';
import 'package:test_pos/features/inventory/presentation/controllers/category_providers.dart';
import 'package:test_pos/features/inventory/presentation/screens/add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditCategoryScreen(),
            ),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return _CategoryTreeList(categories: categories);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CategoryTreeList extends ConsumerWidget {
  final List<CategoryModel> categories;

  const _CategoryTreeList({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group categories by parentId
    final Map<String?, List<CategoryModel>> grouped = {};
    for (var c in categories) {
      final pId = (c.parentId == null || c.parentId!.isEmpty)
          ? null
          : c.parentId;
      if (!grouped.containsKey(pId)) {
        grouped[pId] = [];
      }
      grouped[pId]!.add(c);
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: _buildNodes(context, ref, grouped, null),
    );
  }

  List<Widget> _buildNodes(
    BuildContext context,
    WidgetRef ref,
    Map<String?, List<CategoryModel>> grouped,
    String? parentId,
  ) {
    final children = grouped[parentId] ?? [];
    // Sort by name
    children.sort((a, b) => a.name.compareTo(b.name));

    return children.map((category) {
      final hasSubCategories =
          grouped.containsKey(category.id) && grouped[category.id]!.isNotEmpty;

      // Common actions
      final actions = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditCategoryScreen(category: category),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () => _confirmDelete(context, ref, category),
          ),
        ],
      );

      if (hasSubCategories) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                category.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: category.description != null
                ? Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [actions, const Icon(Icons.expand_more)],
            ),
            childrenPadding: const EdgeInsets.only(left: 16),
            children: _buildNodes(context, ref, grouped, category.id),
          ),
        );
      } else {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.circle, size: 8, color: Colors.grey),
            title: Text(category.name),
            subtitle: category.description != null
                ? Text(
                    category.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: actions,
          ),
        );
      }
    }).toList();
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This might delete or decouple sub-categories.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(categoryListProvider.notifier)
                  .deleteCategory(category.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
