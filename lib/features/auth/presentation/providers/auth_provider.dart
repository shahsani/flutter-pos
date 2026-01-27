import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_model.dart';
import 'package:uuid/uuid.dart';
import '../../utils/password_hasher.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(DatabaseHelper.instance);
});

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  static const _userKey = 'current_user_id';

  @override
  Future<User?> build() async {
    return _loadUser();
  }

  Future<User?> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userKey);
      if (userId != null) {
        final repo = ref.read(authRepositoryProvider);
        return repo.getUserById(userId);
      }
      return null;
    } catch (e) {
      // If error loading user, assume logged out or return null
      return null;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);

      if (await repo.checkEmailExists(email)) {
        throw Exception('Email already exists');
      }

      final user = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password, // In real app, hash this!
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.createUser(user);
      await _saveSession(user.id);
      return user;
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      if (user != null) {
        await _saveSession(user.id);
        return user;
      } else {
        throw Exception('Invalid email or password');
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final user = state.value;
    if (user == null) return;

    try {
      final repo = ref.read(authRepositoryProvider);

      if (email != null && email != user.email) {
        if (await repo.checkEmailExists(email)) {
          throw Exception('Email already exists');
        }
      }

      final updatedUser = user.copyWith(
        name: name,
        email: email,
        updatedAt: DateTime.now(),
      );

      await repo.updateUser(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (error) {
      // Don't change state on error - keep user logged in
      // The UI will need to handle rethrown errors
      rethrow;
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = state.value;
    if (user == null) return;

    try {
      // Verify current password using hash comparison
      if (!PasswordHasher.verifyPassword(currentPassword, user.password)) {
        throw Exception('Current password is incorrect');
      }

      final repo = ref.read(authRepositoryProvider);
      //Hash the new password before storing
      final updatedUser = user.copyWith(
        password: PasswordHasher.hashPassword(newPassword),
        updatedAt: DateTime.now(),
      );

      await repo.updateUser(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (error) {
      // Don't change state on error - keep user logged in
      // The UI will need to handle rethrown errors
      rethrow;
    }
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userId);
  }
}
