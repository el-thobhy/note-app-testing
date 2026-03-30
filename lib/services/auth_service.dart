// services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:note_app/models/note_models.dart';
import 'dio_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _dio = DioClient();
  final _storage = const FlutterSecureStorage();
  
  late Box<UserCache> _userBox;

  Future<void> init() async {
    _userBox = await Hive.openBox<UserCache>('user_cache');
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.login(email, password);
      final data = response.data;
      
      // Simpan token
      await _storage.write(key: 'jwt_token', value: data['token']);
      
      // Simpan user ke Hive (cache)
      // final user = UserCache(
      //   id: data['user']['id'],
      //   email: data['user']['email'],
      //   name: data['user']['name'],
      // );
      // await _userBox.put('current_user', user);
      
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await _dio.register(email, password, name);
      final data = response.data;
      
      await _storage.write(key: 'jwt_token', value: data['token']);
      
      // final user = UserCache(
      //   id: data['user']['id'],
      //   email: data['user']['email'],
      //   name: data['user']['name'],
      // );
      // await _userBox.put('current_user', user);
      
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _userBox.delete('current_user');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  UserCache? getCurrentUser() {
    return _userBox.get('current_user');
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      return e.response?.data['message'] ?? 'Unknown error';
    }
    return e.message ?? 'Network error';
  }
}
