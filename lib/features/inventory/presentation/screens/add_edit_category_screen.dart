import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_pos/core/constants/app_colors.dart';
import 'package:test_pos/features/inventory/domain/models/category_model.dart';
import 'package:test_pos/features/inventory/presentation/controllers/category_providers.dart';
import 'package:uuid/uuid.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel? category;
  final String? parentId; // Pre-select parent if creating from a sub-list

  const AddEditCategoryScreen({super.key, this.category, this.parentId});

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedParentId;

  // We need to know the depth of the selected parent to ensure we don't exceed 3 levels.
  // Level 1: Parent is null.
  // Level 2: Parent is Level 1.
  // Level 3: Parent is Level 2.
  // We cannot choose a parent that is Level 3 (max depth).

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _selectedParentId = widget.category?.parentId ?? widget.parentId;

    // If _selectedParentId is empty string, make it null for consistency
    if (_selectedParentId?.isEmpty ?? true) {
      _selectedParentId = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.category != null;
      final now = DateTime.now();

      final category = CategoryModel(
        id: isEditing ? widget.category!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        parentId: _selectedParentId,
        description: _descriptionController.text.trim(),
        createdAt: isEditing ? widget.category!.createdAt : now,
        updatedAt: now,
      );

      final notifier = ref.read(categoryListProvider.notifier);

      try {
        if (isEditing) {
          await notifier.updateCategory(category);
        } else {
          await notifier.addCategory(category);
        }
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCategoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: allCategoriesAsync.when(
        data: (allCategories) {
          // Filter out valid parents.
          // 1. Cannot be itself (if editing).
          // 2. Parent must have depth < 2 (because if parent is Depth 2 (Level 3 item), child would be Depth 3 (Level 4 item) - invalid).
          // Wait, depth definition:
          // Level 1: depth 0 (no parent)
          // Level 2: depth 1 (parent is Level 1)
          // Level 3: depth 2 (parent is Level 2)
          // So we can pick parent if parent's depth is < 2.

          final validParents = allCategories.where((c) {
            if (widget.category != null && c.id == widget.category!.id)
              return false;

            // Calculate depth of potential parent 'c'
            int depth = 0;
            String? currentParentId = c.parentId;
            while (currentParentId != null && currentParentId.isNotEmpty) {
              if (widget.category != null &&
                  currentParentId == widget.category!.id) {
                return false;
              }
              depth++;
              // Find parentCategory
              final parent = allCategories.firstWhere(
                (element) => element.id == currentParentId,
                orElse: () => c,
              ); // fallback to break loop if needed, though shouldn't happen
              if (parent == c) break; // cycle protection or not found
              currentParentId = parent.parentId;
            }

            // If depth of parent is 0 (Level 1) -> Child will be Level 2. OK.
            // If depth of parent is 1 (Level 2) -> Child will be Level 3. OK.
            // If depth of parent is 2 (Level 3) -> Child will be Level 4. NO.
            return depth < 2;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Parent Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedParentId,
                    decoration: const InputDecoration(
                      labelText: 'Parent Category (Optional)',
                      border: OutlineInputBorder(),
                      helperText: 'Select a parent to make this a sub-category',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('None (Main Category)'),
                      ),
                      ...validParents.map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedParentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Category'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
