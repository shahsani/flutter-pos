import 'package:sqflite/sqflite.dart';
import 'package:test_pos/features/customers/domain/models/customer.dart';
import 'package:test_pos/features/customers/domain/repositories/customer_repository.dart';

import '../../../../core/database/database_helper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper _dbHelper;
  final String _userId;

  CustomerRepositoryImpl(this._dbHelper, this._userId);

  @override
  Future<List<Customer>> getCustomers() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'user_id = ?',
      whereArgs: [_userId],
      orderBy: 'updated_at DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );
    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> createCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    final map = customer.toMap();
    map['user_id'] = _userId;
    await db.insert(
      'customers',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    final map = customer.toMap();
    map['user_id'] = _userId; // Ensure user_id is preserved/set
    await db.update(
      'customers',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [customer.id, _userId],
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'customers',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _userId],
    );
  }
}
