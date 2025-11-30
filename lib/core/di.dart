import 'package:get_it/get_it.dart';
import 'package:my_project/data/datasources/local_user_datasource.dart';
import 'package:my_project/data/repositories/user_repository_impl.dart';
import 'package:my_project/domain/repositories/user_repository.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<LocalUserDataSource>(LocalUserDataSource());
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(getIt<LocalUserDataSource>()),
  );
}
