import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../storage/local_storage.dart';
import '../repositories/auth_repository.dart';
import '../navigation/app_navigator.dart';
import 'package:toastification/toastification.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class DioClient {
  late Dio dio;
  final LocalStorage? storage;
  AuthRepository? authRepository;
  Completer<bool>? _refreshCompleter;

  /// Accept an optional [cookieJar] (use PersistCookieJar to persist across app restarts).
  DioClient(Dio dioInstance, {this.storage, this.authRepository, CookieJar? cookieJar}) {
    dio = dioInstance;

    // Attach a CookieJar + CookieManager so that Set-Cookie from server is respected
    // This helps when the backend uses HTTP-only cookies for session/auth.
    // Note: CookieManager from dio_cookie_manager doesn't work on web,
    // so we only add it for mobile/desktop platforms. On web, Dio uses browser cookies automatically.
    if (!kIsWeb) {
      final _cookieJar = cookieJar ?? CookieJar();
      dio.interceptors.add(CookieManager(_cookieJar));
    }

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
            final skipAuth = options.extra['skipAuth'] == true;
            if (!skipAuth) {
              final token = await storage?.getString(StorageKeys.authToken);
              if (token != null && token.isNotEmpty) {
                // Validate token is a valid JWT string (starts with eyJ for base64 encoded JWT)
                // If it looks like an object string, try to extract the actual token
                String cleanToken = token.trim();
                if (cleanToken.startsWith('{')) {
                  // Token was stored as object string, try to extract access_token
                  try {
                    // Try to parse as JSON and extract access_token
                    final jsonMatch = RegExp(r'"access_token"\s*:\s*"([^"]+)"').firstMatch(cleanToken);
                    if (jsonMatch != null) {
                      cleanToken = jsonMatch.group(1)!;
                      debugPrint('WARNING: Token was stored as object. Extracted clean token.');
                      // Also fix it in storage for future use
                      await storage?.saveString(StorageKeys.authToken, cleanToken);
                    } else {
                      // Fallback: try to extract token-like string
                      final tokenMatch = RegExp(r'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+').firstMatch(cleanToken);
                      if (tokenMatch != null) {
                        cleanToken = tokenMatch.group(0)!;
                        debugPrint('WARNING: Token was stored as object. Extracted JWT from string.');
                        await storage?.saveString(StorageKeys.authToken, cleanToken);
                      }
                    }
                  } catch (e) {
                    debugPrint('Error extracting token from object string: $e');
                  }
                }
                // Only use token if it looks like a valid JWT (starts with eyJ)
                if (cleanToken.startsWith('eyJ')) {
                  options.headers['Authorization'] = 'Bearer $cleanToken';
                } else {
                  debugPrint('DioClient.onRequest -> Invalid token format: ${cleanToken.substring(0, cleanToken.length > 50 ? 50 : cleanToken.length)}...');
                }
              } else {
                // Debug: Log when token is missing
                debugPrint('DioClient.onRequest -> ${options.method} ${options.path} - No token found in storage');
              }
            } else {
              // ensure Authorization header is not sent
              options.headers.remove('Authorization');
            }
            // Debug: print Authorization header for troubleshooting
            assert(() {
              // ignore: avoid_print
              final authHeader = options.headers['Authorization'];
              final displayValue = authHeader != null 
                ? (authHeader.length > 50 ? '${authHeader.substring(0, 50)}...' : authHeader)
                : 'NONE';
              print('DioClient.onRequest -> ${options.method} ${options.path} Authorization=$displayValue');
              return true;
            }());
          } catch (e) {
            debugPrint('DioClient.onRequest error: $e');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final opts = error.requestOptions;

          // If the request explicitly skipped auth, don't attempt refresh for it
          final requestSkippedAuth = opts.extra['skipAuth'] == true;
          if (requestSkippedAuth) {
            handler.next(error);
            return;
          }

          // If we've already retried this request once, avoid retry loops
          final alreadyRetried = opts.extra['retried'] == true;
          if (alreadyRetried) {
            handler.next(error);
            return;
          }

          // Only handle 401
          if (error.response?.statusCode == 401) {
            try {
              // Check if we have a refresh token before attempting refresh
              final refreshToken = await storage?.getString(StorageKeys.refreshToken);
              debugPrint('DioClient: 401 error detected. Refresh token available: ${refreshToken != null && refreshToken.isNotEmpty}');
              
              // If a refresh is already in progress, wait for it to complete
              if (_refreshCompleter != null) {
                final ok = await _refreshCompleter!.future;
                if (ok) {
                  // retry original request once with updated token
                  final token = await storage?.getString(StorageKeys.authToken);
                  if (token != null && token.isNotEmpty) {
                    opts.headers['Authorization'] = 'Bearer $token';
                  } else {
                    opts.headers.remove('Authorization');
                  }
                  opts.extra['retried'] = true;
                  final clonedReq = await dio.fetch(opts);
                  handler.resolve(clonedReq);
                  return;
                }
                // if refresh failed, proceed to error handling below
              } else {
                // If no refresh token available, skip refresh attempt and go directly to logout
                if (refreshToken == null || refreshToken.isEmpty) {
                  debugPrint('DioClient: No refresh token available. Logging out and redirecting to login.');
                  try {
                    await authRepository?.logout();
                  } catch (_) {}
                  try {
                    toastification.show(
                      overlayState: appNavigatorKey.currentState?.overlay,
                      title: const Text('Phiên đã hết hạn'),
                      description: const Text('Vui lòng đăng nhập lại'),
                      type: ToastificationType.warning,
                      style: ToastificationStyle.fillColored,
                      autoCloseDuration: const Duration(seconds: 4),
                    );
                  } catch (_) {}
                  try {
                    final nav = appNavigatorKey.currentState;
                    if (nav != null) {
                      final ctx = nav.context;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog<void>(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Phiên đã hết hạn'),
                            content: const Text('Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dctx).pop();
                                  nav.pushNamedAndRemoveUntil('/login', (r) => false, arguments: {
                                    'autoLogout': true,
                                    'message': 'Session expired, please log in again'
                                  });
                                },
                                child: const Text('Đăng nhập'),
                              ),
                            ],
                          ),
                        );
                      });
                    }
                  } catch (_) {}
                  handler.next(error);
                  return;
                }

                // start a refresh flow and notify waiters via completer
                _refreshCompleter = Completer<bool>();

                bool success = false;
                try {
                  debugPrint('DioClient: Attempting to refresh token...');
                  // Primary refresh attempt via repository helper which may parse and persist tokens
                  success = await authRepository?.refreshToken() ?? false;
                  debugPrint('DioClient: Refresh token result: $success');

                  // If repo did not find tokens (server might use headers/cookies), try a raw refresh
                  if (!success) {
                    final refreshValue = await storage?.getString(StorageKeys.refreshToken);
                    if (refreshValue != null && refreshValue.isNotEmpty) {
                      try {
                        final rawResp = await dio.post(
                          '/auth/refresh-token',
                          data: {'refresh_token': refreshValue},
                          options: Options(extra: {'skipAuth': true}, validateStatus: (_) => true),
                        );

                        assert(() {
                          // ignore: avoid_print
                          print('Raw refreshResp status=${rawResp.statusCode} data=${rawResp.data} headers=${rawResp.headers}');
                          return true;
                        }());

                        // Try headers first
                        String? headerToken;
                        final hmap = rawResp.headers.map;
                        final headerCandidates = ['authorization', 'x-access-token', 'x-auth-token', 'x-token'];
                        for (final key in headerCandidates) {
                          if (hmap.containsKey(key)) {
                            final v = rawResp.headers.value(key);
                            if (v != null && v.isNotEmpty) {
                              headerToken = v;
                              break;
                            }
                          }
                        }

                        if (headerToken != null && headerToken.isNotEmpty) {
                          final cleaned = headerToken.replaceFirst(RegExp(r'^(Bearer\s+)', caseSensitive: false), '');
                          await storage?.saveString(StorageKeys.authToken, cleaned);
                          success = true;
                        }

                        // Inspect Set-Cookie for token names
                        if (!success) {
                          final cookies = rawResp.headers.map['set-cookie'];
                          if (cookies != null) {
                            for (final cookie in cookies) {
                              final m1 = RegExp(r'access[_-]?token=([^;]+)').firstMatch(cookie);
                              final m2 = RegExp(r'auth[_-]?token=([^;]+)').firstMatch(cookie);
                              final m3 = RegExp(r'jwt=([^;]+)').firstMatch(cookie);
                              final candidate = m1?.group(1) ?? m2?.group(1) ?? m3?.group(1);
                              if (candidate != null && candidate.isNotEmpty) {
                                await storage?.saveString(StorageKeys.authToken, candidate);
                                success = true;
                                break;
                              }
                            }
                          }
                        }

                        // If server returned JSON body, try to extract tokens from it
                        if (!success && rawResp.data != null && rawResp.data is Map<String, dynamic>) {
                          try {
                            final bodyMap = Map<String, dynamic>.from(rawResp.data as Map);
                            final extracted = _extractTokensFromMapLocal(bodyMap);
                            if (extracted.accessToken != null) {
                              await storage?.saveString(StorageKeys.authToken, extracted.accessToken!);
                              success = true;
                            }
                            if (extracted.refreshToken != null) {
                              await storage?.saveString(StorageKeys.refreshToken, extracted.refreshToken!);
                            }
                          } catch (_) {}
                        }
                      } catch (_) {}
                    }
                  }
                } finally {
                  // notify waiters
                  try {
                    _refreshCompleter?.complete(success);
                  } catch (_) {}
                  _refreshCompleter = null;
                }

                if (success) {
                  // retry original request once
                  final token = await storage?.getString(StorageKeys.authToken);
                  if (token != null && token.isNotEmpty) {
                    opts.headers['Authorization'] = 'Bearer $token';
                  } else {
                    opts.headers.remove('Authorization');
                  }
                  opts.extra['retried'] = true;
                  final clonedReq = await dio.fetch(opts);
                  handler.resolve(clonedReq);
                  return;
                }

                // refresh failed -> logout and redirect to login
                debugPrint('DioClient: Token refresh failed. Logging out and redirecting to login.');
                try {
                  await authRepository?.logout();
                } catch (_) {}
                try {
                  toastification.show(
                    overlayState: appNavigatorKey.currentState?.overlay,
                    title: const Text('Phiên đã hết hạn'),
                    description: const Text('Vui lòng đăng nhập lại'),
                    type: ToastificationType.warning,
                    style: ToastificationStyle.fillColored,
                    autoCloseDuration: const Duration(seconds: 4),
                  );
                } catch (_) {}

                // Instead of forcing immediate navigation to the login screen
                // show a dialog allowing the user to re-login or be redirected manually.
                try {
                  final nav = appNavigatorKey.currentState;
                  if (nav != null) {
                    final ctx = nav.context;
                    // Use a post-frame callback to ensure dialog shows correctly
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog<void>(
                        context: ctx,
                        barrierDismissible: false,
                        builder: (dctx) => AlertDialog(
                          title: const Text('Phiên đã hết hạn'),
                          content: const Text('Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dctx).pop();
                                try {
                                  nav.pushNamedAndRemoveUntil('/login', (r) => false, arguments: {
                                    'autoLogout': true,
                                    'message': 'Session expired, please log in again'
                                  });
                                } catch (_) {
                                  // fallback: push to login without clearing stack
                                  nav.pushNamed('/login', arguments: {
                                    'autoLogout': true,
                                    'message': 'Session expired, please log in again'
                                  });
                                }
                              },
                              child: const Text('Đăng nhập'),
                            ),
                          ],
                        ),
                      );
                    });
                  }
                } catch (_) {}
              }
            } catch (_) {
              // ignore and pass error to next handler
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

  // Local token extraction helper (duplicate of AuthRepository logic but internal)
  _TokenPair _extractTokensFromMapLocal(Map<String, dynamic> map) {
    String? access;
    String? refresh;

    void checkMap(Map<String, dynamic> m) {
      // common keys for access token (ONLY string values, NOT wrapper objects)
      // Note: 'token' is NOT included here because it's a wrapper object, not a token value
      final accessKeys = [
        'access_token',
        'accessToken',
        'auth_token',
        'id_token',
        'jwt',
      ];
      // common keys for refresh token
      final refreshKeys = ['refresh_token', 'refreshToken'];
      
      // Check for access token - ONLY accept String values
      for (final k in accessKeys) {
        if (access != null) break;
        if (m.containsKey(k) && m[k] != null) {
          final value = m[k];
          // ONLY accept String values, ignore objects/Maps
          if (value is String && value.isNotEmpty) {
            access = value;
          }
        }
      }
      
      // Check for refresh token - ONLY accept String values
      for (final k in refreshKeys) {
        if (refresh != null) break;
        if (m.containsKey(k) && m[k] != null) {
          final value = m[k];
          // ONLY accept String values, ignore objects/Maps
          if (value is String && value.isNotEmpty) {
            refresh = value;
          }
        }
      }
    }

    // Priority 1: Check 'token' wrapper first (most common for your API)
    if (map['token'] is Map<String, dynamic>) {
      checkMap(map['token'] as Map<String, dynamic>);
    }
    
    // Priority 2: Check top-level
    if (access == null || refresh == null) {
      checkMap(map);
    }
    
    // Priority 3: Check common wrapper keys
    if ((access == null || refresh == null) && map['data'] is Map<String, dynamic>) {
      checkMap(map['data'] as Map<String, dynamic>);
    }
    if ((access == null || refresh == null) && map['result'] is Map<String, dynamic>) {
      checkMap(map['result'] as Map<String, dynamic>);
    }
    if ((access == null || refresh == null) && map['auth'] is Map<String, dynamic>) {
      checkMap(map['auth'] as Map<String, dynamic>);
    }
    
    // Priority 4: Check if any immediate child maps contain tokens (one level deep)
    if (access == null || refresh == null) {
      for (final v in map.values) {
        if (v is Map<String, dynamic>) {
          checkMap(v);
          if (access != null && refresh != null) break;
        }
      }
    }

    return _TokenPair(access, refresh);
  }
}

class _TokenPair {
  final String? accessToken;
  final String? refreshToken;

  _TokenPair(this.accessToken, this.refreshToken);
}
