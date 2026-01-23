import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const numType = 'REAL'; // Floating point
    const intType = 'INTEGER';

    // Customers
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType NOT NULL,
        phone $textType,
        email $textType,
        address $textType,
        created_at $intType,
        updated_at $intType
      )
    ''');
    
    // Categories
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType NOT NULL,
        parent_id $textType,
        description $textType,
        created_at $intType,
        updated_at $intType
      )
    ''');

    // Products
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType NOT NULL,
        sku $textType UNIQUE,
        barcode $textType UNIQUE,
        category_id $textType,
        cost_price $numType,
        selling_price $numType,
        stock_quantity $intType,
        min_stock_level $intType DEFAULT 0,
        description $textType,
        image_path $textType,
        created_at $intType,
        updated_at $intType,
        FOREIGN KEY(category_id) REFERENCES categories(id)
      )
    ''');

    // Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id $idType,
        name $textType NOT NULL,
        contact $textType,
        email $textType,
        address $textType,
        created_at $intType,
        updated_at $intType
      )
    ''');

    // Sales
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        invoice_number $textType UNIQUE,
        customer_id $textType,
        total_amount $numType,
        discount $numType DEFAULT 0.0,
        tax $numType DEFAULT 0.0,
        payment_method $textType,
        sale_date $intType,
        created_at $intType,
        FOREIGN KEY(customer_id) REFERENCES customers(id)
      )
    ''');

    // Sale Items
    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        sale_id $textType NOT NULL,
        product_id $textType NOT NULL,
        quantity $intType,
        unit_price $numType,
        subtotal $numType,
        discount $numType DEFAULT 0.0,
        FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');

    // Stock Transactions
    await db.execute('''
      CREATE TABLE stock_transactions (
        id $idType,
        product_id $textType NOT NULL,
        transaction_type $textType,
        quantity $intType,
        reference_number $textType,
        notes $textType,
        transaction_date $intType,
        created_at $intType,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
