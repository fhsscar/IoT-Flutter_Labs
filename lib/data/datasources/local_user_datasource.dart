// lib/data/datasources/local_user_datasource.dart

import 'dart:convert';

import 'package:my_project/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserDataSource {
  static const String _key = 'current_user';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
    // ignore: avoid_print
    print('ЗБЕРЕЖЕНО: ${user.email}');
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);

    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      // ignore: avoid_print
      print('Помилка читання користувача: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
