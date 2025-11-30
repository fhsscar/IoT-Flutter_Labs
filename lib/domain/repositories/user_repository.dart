import 'package:my_project/domain/models/user.dart';

abstract class UserRepository {
  Future<void> register(User user);
  Future<User?> login(String email, String password);
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
}
