import 'package:dio/dio.dart';

/// Simple fetcher wrapper to normalize API calls and errors.
class Fetcher {
  final Dio dio;

  Fetcher(this.dio);

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final resp = await dio.get(path, queryParameters: queryParameters);
      return resp.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final resp = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return resp.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      return Exception(
        'Request failed: ${e.response?.statusCode} ${e.response?.statusMessage} ${e.response?.data}',
      );
    }
    return Exception('Network error: ${e.message}');
  }
}
