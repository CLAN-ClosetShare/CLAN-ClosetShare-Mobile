import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../storage/local_storage.dart';
import '../repositories/auth_repository.dart';
import '../navigation/app_navigator.dart';
import 'package:toastification/toastification.dart';

class DioClient {
  late Dio dio;
  final LocalStorage? storage;
  AuthRepository? authRepository;
  Completer<bool>? _refreshCompleter;

  DioClient(Dio dioInstance, {this.storage, this.authRepository}) {
    dio = dioInstance;

    // Base configuration from env
    final envBase = dotenv.env['API_BASE_URL']?.trim();
    // If dotenv not set or empty, fallback to the project's backend IP.
    final base = (envBase != null && envBase.isNotEmpty)
        ? envBase
        : 'http://103.163.24.150:3000';
    // Log chosen base for easier debugging
    try {
      // debugPrint is safe in all builds but only prints in debug mode
      // (kept as informative message for developers)
      // ignore: avoid_print
      debugPrint('DioClient: using base URL => $base');
    } catch (_) {}
    dio.options = BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // Auth interceptor with refresh-token flow
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage?.getString(StorageKeys.authToken);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
          handler.next(options);
        },
        onError: (error, handler) async {
          // If 401, try refresh token flow
          if (error.response?.statusCode == 401) {
            try {
              final opts = error.requestOptions;

              // If a refresh is already in progress, wait for it
              if (_refreshCompleter != null) {
                final ok = await _refreshCompleter!.future;
                if (ok) {
                  // retry original request
                  final token = await storage?.getString(StorageKeys.authToken);
                  if (token != null) {
                    opts.headers['Authorization'] = 'Bearer $token';
                  }
                  final clonedReq = await dio.fetch(opts);
                  handler.resolve(clonedReq);
                  return;
                }
                // If refresh failed, continue to error
                handler.next(error);
                return;
              }

              // start refresh
              _refreshCompleter = Completer<bool>();
              final success = await authRepository?.refreshToken() ?? false;
              _refreshCompleter!.complete(success);
              _refreshCompleter = null;

              if (success) {
                // retry original request
                final token = await storage?.getString(StorageKeys.authToken);
                if (token != null) {
                  opts.headers['Authorization'] = 'Bearer $token';
                }
                final clonedReq = await dio.fetch(opts);
                handler.resolve(clonedReq);
                return;
              }
              // refresh failed -> logout and redirect to login
              try {
                await authRepository?.logout();
              } catch (_) {}
              // show toast using toastification (overlay from navigator key)
              try {
                toastification.show(
                  overlayState: appNavigatorKey.currentState?.overlay,
                  title: const Text('Session expired'),
                  description: const Text('Please log in again'),
                  type: ToastificationType.warning,
                  style: ToastificationStyle.fillColored,
                  autoCloseDuration: const Duration(seconds: 4),
                );
              } catch (_) {}

              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (r) => false,
              );
            } catch (_) {
              // fallthrough to next
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
