import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<bool> login(String email, String password) =>
      _dataSource.login(email, password);

  @override
  Future<bool> register(String email, String password, String name) =>
      _dataSource.register(email, password, name);

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<bool> isLoggedIn() => _dataSource.isLoggedIn();
}
