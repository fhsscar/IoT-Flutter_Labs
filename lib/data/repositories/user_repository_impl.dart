// lib/data/repositories/user_repository_impl.dart

import 'package:my_project/data/datasources/local_user_datasource.dart';
import 'package:my_project/domain/models/user.dart';
import 'package:my_project/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource _dataSource;

  const UserRepositoryImpl(this._dataSource);

  @override
  Future<void> register(User user) async {
    await _dataSource.saveUser(user);
  }

  @override
  Future<User?> login(String email, String password) async {
    final user = await _dataSource.getUser();
    if (user != null && user.email == email && user.password == password) {
      await _dataSource.saveUser(user); // ЗБЕРІГАЄМО ПРИ ЛОГІНІ!
      return user;
    }
    return null;
  }

  @override
  Future<User?> getCurrentUser() => _dataSource.getUser();

  @override
  Future<void> updateUser(User user) async {
    await _dataSource.saveUser(user);
  }
}
