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
      if (extracted.accessToken != null) {
        await storage.saveString(StorageKeys.authToken, extracted.accessToken!);
      }
      if (extracted.refreshToken != null) {
        await storage.saveString(
          StorageKeys.refreshToken,
          extracted.refreshToken!,
        );
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
      // common keys
      final accessKeys = [
        'access_token',
        'accessToken',
        'token',
        'auth_token',
        'id_token',
        'jwt',
      ];
      final refreshKeys = ['refresh_token', 'refreshToken'];
      for (final k in accessKeys) {
        if (access != null) break;
        if (m.containsKey(k) && m[k] != null) access = m[k].toString();
      }
      for (final k in refreshKeys) {
        if (refresh != null) break;
        if (m.containsKey(k) && m[k] != null) refresh = m[k].toString();
      }
    }

    // Check top-level
    checkMap(map);
    // Check common wrapper keys
    if ((access == null || refresh == null) && map['data'] is Map<String, dynamic>) {
      checkMap(map['data'] as Map<String, dynamic>);
    }
    if ((access == null || refresh == null) && map['result'] is Map<String, dynamic>) {
      checkMap(map['result'] as Map<String, dynamic>);
    }
    // Also check 'token' or 'auth' wrapper commonly used by some APIs
    if ((access == null || refresh == null) && map['token'] is Map<String, dynamic>) {
      checkMap(map['token'] as Map<String, dynamic>);
    }
    if ((access == null || refresh == null) && map['auth'] is Map<String, dynamic>) {
      checkMap(map['auth'] as Map<String, dynamic>);
    }
    // Also check if any immediate child maps contain tokens (one level deep)
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
