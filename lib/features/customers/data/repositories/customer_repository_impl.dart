import 'package:sqflite/sqflite.dart';
import 'package:test_pos/features/customers/domain/models/customer.dart';
import 'package:test_pos/features/customers/domain/repositories/customer_repository.dart';

import '../../../../core/database/database_helper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper _dbHelper;

  CustomerRepositoryImpl(this._dbHelper);

  @override
  Future<List<Customer>> getCustomers() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', orderBy: 'updated_at DESC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> createCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
