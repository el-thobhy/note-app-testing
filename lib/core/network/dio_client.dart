import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  static const String authBaseUrl = 'https://expense-app.el-thobhy.my.id/api';
  static const String notesBaseUrl = 'note-app-be.zeabur.app';

  void init() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
        }
        return handler.next(error);
      },
    ));
  }

  // Auth
  Future<Response> login(String email, String password) =>
      dio.post('$authBaseUrl/Users/login', data: {'email': email, 'password': password});

  Future<Response> register(String email, String password, String name) =>
      dio.post('$authBaseUrl/Users/register', data: {'email': email, 'password': password, 'name': name});

  // Notes
  Future<Response> getNotes() => dio.get('$notesBaseUrl/notes');
  Future<Response> createNote(Map<String, dynamic> data) => dio.post('$notesBaseUrl/notes', data: data);
  Future<Response> updateNote(String id, Map<String, dynamic> data) => dio.put('$notesBaseUrl/notes/$id', data: data);
  Future<Response> deleteNote(String id) => dio.delete('$notesBaseUrl/notes/$id');
}
