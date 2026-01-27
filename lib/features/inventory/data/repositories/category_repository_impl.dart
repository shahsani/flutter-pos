import 'package:sqflite/sqflite.dart';
import 'package:test_pos/core/database/database_helper.dart';
import 'package:test_pos/features/inventory/domain/models/category_model.dart';
import 'package:test_pos/features/inventory/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _dbHelper;
  final String _userId;

  CategoryRepositoryImpl(this._dbHelper, this._userId);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [_userId],
      orderBy: 'updated_at DESC',
    );
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getSubCategories(String parentId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'parent_id = ? AND user_id = ?',
      whereArgs: [parentId, _userId],
      orderBy: 'name ASC', // Usually subcategories are ordered by name
    );
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );

    if (result.isNotEmpty) {
      return CategoryModel.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.insert(
      'categories',
      category.toMap()..['user_id'] = _userId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      category.toMap()..['user_id'] = _userId,
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, _userId],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );
  }
}
