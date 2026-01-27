import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  /// Hash a password using SHA-256
  /// In production, consider using bcrypt or argon2 for better security
  static String hashPassword(String password) {
    // Add a salt for additional security
    // In a real app, you might want to use a per-user salt stored in the database
    const salt =
        'flutter_pos_salt_2024'; // Change this to a secure random value
    final saltedPassword = password + salt;
    final bytes = utf8.encode(saltedPassword);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verify a password against a hash
  static bool verifyPassword(String password, String hashedPassword) {
    final inputHash = hashPassword(password);
    return inputHash == hashedPassword;
  }
}
