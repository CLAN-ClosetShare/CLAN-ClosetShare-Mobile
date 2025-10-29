import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class AuthRepository {
  final Dio dio;
  final LocalStorage storage;

  AuthRepository(this.dio, this.storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final resp = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      // Debug logging in development
      assert(() {
        // ignore: avoid_print
        print(
          'AuthRepository.login response: status=${resp.statusCode}, data=${resp.data}, headers=${resp.headers}',
        );
        return true;
      }());
      final raw = resp.data;
      if (raw == null) {
        // If server returned a successful HTTP status but empty body, treat as success
        final status = resp.statusCode ?? 0;
        if (status >= 200 && status < 300) {
          return <String, dynamic>{};
        }
        throw Exception(
          'Login failed: empty response from server (status $status)',
        );
      }
      if (raw is! Map<String, dynamic>) {
        // Try to coerce other JSON shapes into a map by wrapping
        // but normally we expect a JSON object here.
        throw Exception(
          'Login failed: unexpected response shape: ${raw.runtimeType}',
        );
      }
      final data = raw;
      // Attempt to extract and persist tokens from a variety of response shapes.
      final extracted = _extractTokensFromMap(data);
      
      // Debug logging
      assert(() {
        // ignore: avoid_print
        print('AuthRepository.login: Extracted tokens - accessToken: ${extracted.accessToken != null ? "EXISTS (${extracted.accessToken!.substring(0, 20)}...)" : "NULL"}, refreshToken: ${extracted.refreshToken != null ? "EXISTS (${extracted.refreshToken!.substring(0, 20)}...)" : "NULL"}');
        return true;
      }());
      
      if (extracted.accessToken != null) {
        final tokenString = extracted.accessToken!.trim();
        // Validate token is a valid JWT string (should start with eyJ for base64 encoded JWT)
        if (tokenString.startsWith('eyJ')) {
          await storage.saveString(StorageKeys.authToken, tokenString);
          // Verify token was saved correctly
          final saved = await storage.getString(StorageKeys.authToken);
          assert(() {
            // ignore: avoid_print
            print('AuthRepository.login: Token saved to storage: ${saved != null && saved.isNotEmpty && saved.startsWith("eyJ")}');
            if (saved != null && !saved.startsWith('eyJ')) {
              print('ERROR: Token was not saved correctly! Value: ${saved.substring(0, saved.length > 100 ? 100 : saved.length)}');
            }
            return true;
          }());
        } else {
          assert(() {
            // ignore: avoid_print
            print('ERROR: Invalid token format! Token starts with: ${tokenString.substring(0, tokenString.length > 20 ? 20 : tokenString.length)}');
            return true;
          }());
        }
      }
      if (extracted.refreshToken != null) {
        final refreshString = extracted.refreshToken!.trim();
        // Validate refresh token is a valid JWT string
        if (refreshString.startsWith('eyJ')) {
          await storage.saveString(StorageKeys.refreshToken, refreshString);
          // Verify refresh token was saved correctly
          final savedRefresh = await storage.getString(StorageKeys.refreshToken);
          assert(() {
            // ignore: avoid_print
            print('AuthRepository.login: Refresh token saved to storage: ${savedRefresh != null && savedRefresh.isNotEmpty && savedRefresh.startsWith("eyJ")}');
            if (savedRefresh != null && !savedRefresh.startsWith('eyJ')) {
              print('ERROR: Refresh token was not saved correctly! Value: ${savedRefresh.substring(0, savedRefresh.length > 100 ? 100 : savedRefresh.length)}');
            }
            return true;
          }());
        } else {
          assert(() {
            // ignore: avoid_print
            print('ERROR: Invalid refresh token format! Token starts with: ${refreshString.substring(0, refreshString.length > 20 ? 20 : refreshString.length)}');
            return true;
          }());
        }
      }
      return data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception(
        'Login failed${status != null ? ' (status $status)' : ''}: ${body ?? e.message}',
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Check if user has a valid token in storage
  /// Returns true if token exists and is valid format, false otherwise
  /// Note: This doesn't validate token with server - that happens automatically via interceptor
  Future<bool> isAuthenticated() async {
    final token = await storage.getString(StorageKeys.authToken);
    if (token == null || token.isEmpty) return false;
    
    // Clean token if it's stored as object string
    String cleanToken = token.trim();
    if (cleanToken.startsWith('{')) {
      try {
        // Try to extract token from object string
        final jsonMatch = RegExp(r'"access_token"\s*:\s*"([^"]+)"').firstMatch(cleanToken);
        if (jsonMatch != null) {
          cleanToken = jsonMatch.group(1)!;
          await storage.saveString(StorageKeys.authToken, cleanToken);
        } else {
          // Fallback: extract JWT pattern
          final tokenMatch = RegExp(r'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+').firstMatch(cleanToken);
          if (tokenMatch != null) {
            cleanToken = tokenMatch.group(0)!;
            await storage.saveString(StorageKeys.authToken, cleanToken);
          } else {
            return false; // Cannot extract valid token
          }
        }
      } catch (_) {
        return false;
      }
    }
    
    // Token must be a valid JWT format (starts with eyJ)
    // Actual validation happens when API is called via interceptor
    return cleanToken.startsWith('eyJ');
  }

  Future<void> logout() async {
    await storage.remove(StorageKeys.authToken);
    await storage.remove(StorageKeys.refreshToken);
  }

  /// Try to refresh tokens using stored refresh token. Returns true if success.
  Future<bool> refreshToken() async {
    final refresh = await storage.getString(StorageKeys.refreshToken);
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final resp = await dio.post(
        '/auth/refresh-token',
        data: {'refresh_token': refresh},
        options: Options(extra: {'skipAuth': true}),
      );
      assert(() {
        // ignore: avoid_print
        print(
          'AuthRepository.refreshToken response: status=${resp.statusCode}, data=${resp.data}, headers=${resp.headers}',
        );
        return true;
      }());

      // Check headers / cookies for tokens first (some servers return tokens in headers)
      try {
        final headersMap = resp.headers.map;
        String? headerToken;
        final headerCandidates = ['authorization', 'x-access-token', 'x-auth-token', 'x-token'];
        for (final key in headerCandidates) {
          if (headersMap.containsKey(key)) {
            final v = resp.headers.value(key);
            if (v != null && v.isNotEmpty) {
              headerToken = v;
              break;
            }
          }
        }
        if (headerToken != null && headerToken.isNotEmpty) {
          final cleaned = headerToken.replaceFirst(RegExp(r'^(Bearer\s+)', caseSensitive: false), '');
          await storage.saveString(StorageKeys.authToken, cleaned);
          return true;
        }

        // Inspect Set-Cookie for token names
        final cookies = headersMap['set-cookie'];
        if (cookies != null) {
          for (final cookie in cookies) {
            final m1 = RegExp(r'access[_-]?token=([^;]+)').firstMatch(cookie);
            final m2 = RegExp(r'auth[_-]?token=([^;]+)').firstMatch(cookie);
            final m3 = RegExp(r'jwt=([^;]+)').firstMatch(cookie);
            final candidate = m1?.group(1) ?? m2?.group(1) ?? m3?.group(1);
            if (candidate != null && candidate.isNotEmpty) {
              await storage.saveString(StorageKeys.authToken, candidate);
              return true;
            }
          }
        }
      } catch (_) {}

      final raw = resp.data;
      if (raw == null) {
        final status = resp.statusCode ?? 0;
        if (status >= 200 && status < 300) return true;
        return false;
      }
      if (raw is! Map<String, dynamic>) return false;
      final data = raw;
      final extracted = _extractTokensFromMap(data);
      if (extracted.accessToken != null) {
        await storage.saveString(StorageKeys.authToken, extracted.accessToken!);
      }
      if (extracted.refreshToken != null) {
        await storage.saveString(
          StorageKeys.refreshToken,
          extracted.refreshToken!,
        );
      }
      // Consider refresh successful only if an access token was extracted and persisted.
      // Do NOT treat an empty 2xx response as a successful token refresh — that causes
      // the client to retry requests without a token and leads to immediate 401s.
      return extracted.accessToken != null;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Small helper to hold extracted token pair
  _TokenPair _extractTokensFromMap(Map<String, dynamic> map) {
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
