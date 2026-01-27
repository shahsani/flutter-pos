import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_pos/core/database/database_helper.dart';
import 'package:test_pos/features/inventory/data/repositories/category_repository_impl.dart';
import 'package:test_pos/features/inventory/domain/models/category_model.dart';
import 'package:test_pos/features/inventory/domain/repositories/category_repository.dart';

// Repository Provider
import '../../../auth/presentation/providers/auth_provider.dart';

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  return CategoryRepositoryImpl(DatabaseHelper.instance, userId);
});

// Implementation of a notifier to manage the list of categories and allow real-time updates
// Since sqflite doesn't stream by default, we'll implement a state notifier or use a FutureProvider that we invalidate.
// For better UX during add/edit, we will use AsyncNotifier.

class CategoryListNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    return _fetchCategories();
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    return repository.getCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  Future<void> addCategory(CategoryModel category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.createCategory(category);
    // Refresh to update the list
    ref.invalidateSelf();
  }

  Future<void> updateCategory(CategoryModel category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.updateCategory(category);
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String id) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.deleteCategory(id);
    ref.invalidateSelf();
  }
}

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<CategoryModel>>(
      CategoryListNotifier.new,
    );

// Helper providers for specific filtering
// Note: These might re-compute when categoryListProvider updates

final parentCategoriesProvider = Provider<AsyncValue<List<CategoryModel>>>((
  ref,
) {
  final categoriesAsync = ref.watch(categoryListProvider);
  return categoriesAsync.whenData((categories) {
    return categories
        .where((c) => c.parentId == null || c.parentId!.isEmpty)
        .toList();
  });
});

final subCategoriesProvider =
    Provider.family<AsyncValue<List<CategoryModel>>, String>((ref, parentId) {
      final categoriesAsync = ref.watch(categoryListProvider);
      return categoriesAsync.whenData((categories) {
        return categories.where((c) => c.parentId == parentId).toList();
      });
    });

// Fetch a single category by ID (good for edits)
final categoryByIdProvider = FutureProvider.family<CategoryModel?, String>((
  ref,
  id,
) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getCategoryById(id);
});
