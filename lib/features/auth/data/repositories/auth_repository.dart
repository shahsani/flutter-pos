import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/models/user_model.dart';
import '../../utils/password_hasher.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper;

  AuthRepository(this._databaseHelper);

  Future<User> createUser(User user) async {
    final db = await _databaseHelper.database;
    // Hash the password before storing
    final hashedUser = user.copyWith(
      password: PasswordHasher.hashPassword(user.password),
    );
    await db.insert(
      'users',
      hashedUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail, // Email must be unique
    );
    return hashedUser;
  }

  Future<User?> login(String email, String password) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      // Verify password hash
      if (PasswordHasher.verifyPassword(password, user.password)) {
        return user;
      }
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> updateUser(User user) async {
    final db = await _databaseHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
