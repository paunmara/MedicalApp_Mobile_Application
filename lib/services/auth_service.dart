import 'package:flutter/foundation.dart';
import 'package:bcrypt/bcrypt.dart';
import '../db/database_helper.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? currentUser;

  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }

  Future<String?> login(String username, String password) async {
    final user = await DatabaseHelper.instance.getUserByUsername(
      username.trim().toLowerCase(),
    );

    if (user == null || !verifyPassword(password, user['password_hash'] as String)) {
      return 'Nume de utilizator sau parolă incorectă';
    }

    currentUser = user;
    notifyListeners();
    return null;
  }

  Future<String?> createFirstAdmin(String username, String password, String confirm) async {
    final cleanUsername = username.trim().toLowerCase();

    if (cleanUsername.isEmpty || password.isEmpty) {
      return 'Numele de utilizator și parola sunt obligatorii.';
    }
    if (password != confirm) {
      return 'Parolele nu coincid.';
    }
    if (password.length < 8) {
      return 'Parola trebuie să aibă minim 8 caractere.';
    }

    final hash = hashPassword(password);
    final id = await DatabaseHelper.instance.createUser(
      username: cleanUsername,
      passwordHash: hash,
      isAdmin: true,
    );

    currentUser = {
      'id': id,
      'username': cleanUsername,
      'password_hash': hash,
      'is_admin': 1,
    };
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  Future<String?> createRegularUser(
      String username,
      String password,
      String confirmPassword,
      ) async {
    final cleanUsername = username.trim().toLowerCase();

    if (cleanUsername.isEmpty || password.isEmpty) {
      return 'Numele de utilizator și parola sunt obligatorii.';
    }
    if (password != confirmPassword) {
      return 'Parolele nu coincid.';
    }
    if (password.length < 8) {
      return 'Parola trebuie să aibă minim 8 caractere.';
    }

    final existing = await DatabaseHelper.instance.getUserByUsername(cleanUsername);
    if (existing != null) {
      return 'Acest username este deja folosit.';
    }

    final hash = hashPassword(password);
    await DatabaseHelper.instance.createUser(
      username: cleanUsername,
      passwordHash: hash,
      isAdmin: false,
    );

    return null;
  }

  bool get isAdmin => currentUser != null && currentUser!['is_admin'] == 1;
}