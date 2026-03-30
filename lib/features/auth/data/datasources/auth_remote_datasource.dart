import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String email, String password);
  Future<bool> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isLoggedIn();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSourceImpl({
    required DioClient client,
    required FlutterSecureStorage storage,
  })  : _client = client,
        _storage = storage;

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.login(email, password);
      final token = response.data['token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message ?? 'Login failed';
    }
  }

  @override
  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _client.register(email, password, name);
      final token = response.data['token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? e.message ?? 'Register failed';
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
