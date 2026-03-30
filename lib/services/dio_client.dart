// services/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  // URL Config
  static const String authBaseUrl = 'https://expense-app.el-thobhy.my.id/api';  // Auth Service
  static const String notesBaseUrl = 'note-app-be.zeabur.app'; // Note Service

  void init() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Logging (debug only)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }

    // JWT Interceptor
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
          // Token expired, coba refresh atau logout
          await _storage.delete(key: 'jwt_token');
          // Bisa tambah navigation ke login di sini
        }
        return handler.next(error);
      },
    ));
  }

  // Auth APIs
  Future<Response> login(String email, String password) async {
    return await dio.post(
      '$authBaseUrl/Users/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> register(String email, String password, String name) async {
    return await dio.post(
      '$authBaseUrl/Users/register',
      data: {'email': email, 'password': password, 'name': name},
    );
  }

  // Note APIs
  Future<Response> getNotes() async {
    return await dio.get('$notesBaseUrl/notes');
  }

  Future<Response> getNoteById(String id) async {
    return await dio.get('$notesBaseUrl/notes/$id');
  }

  Future<Response> createNote(Map<String, dynamic> data) async {
    return await dio.post('$notesBaseUrl/notes', data: data);
  }

  Future<Response> updateNote(String id, Map<String, dynamic> data) async {
    return await dio.put('$notesBaseUrl/notes/$id', data: data);
  }

  Future<Response> deleteNote(String id) async {
    return await dio.delete('$notesBaseUrl/notes/$id');
  }

  Future<Response> togglePin(String id) async {
    return await dio.post('$notesBaseUrl/notes/$id/pin');
  }

  Future<Response> toggleArchive(String id) async {
    return await dio.post('$notesBaseUrl/notes/$id/archive');
  }
}