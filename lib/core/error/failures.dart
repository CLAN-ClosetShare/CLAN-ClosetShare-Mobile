import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Base Failure class
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Server Failure
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

// Error Handler
class ErrorHandler {
  static Failure handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return UnknownFailure(error.toString());
    } else {
      return const UnknownFailure('Đã xảy ra lỗi không xác định');
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure('Kết nối bị timeout');
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Gửi dữ liệu bị timeout');
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Nhận dữ liệu bị timeout');
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return const NetworkFailure('Yêu cầu bị hủy');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Không có kết nối internet');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Chứng chỉ không hợp lệ');
      default:
        return const UnknownFailure('Đã xảy ra lỗi không xác định');
    }
  }

  static Failure _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _getErrorMessage(statusCode);
    return ServerFailure(message, statusCode: statusCode);
  }

  static String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ';
      case 401:
        return 'Bạn chưa đăng nhập';
      case 403:
        return 'Bạn không có quyền truy cập';
      case 404:
        return 'Không tìm thấy dữ liệu';
      case 409:
        return 'Dữ liệu đã tồn tại';
      case 422:
        return 'Dữ liệu không hợp lệ';
      case 500:
        return 'Lỗi máy chủ nội bộ';
      case 502:
        return 'Máy chủ không phản hồi';
      case 503:
        return 'Máy chủ đang bảo trì';
      default:
        return 'Đã xảy ra lỗi từ máy chủ';
    }
  }

  // Get user-friendly error message
  static String getDisplayMessage(Failure failure) {
    if (failure is ServerFailure) {
      if (failure.statusCode == 401) {
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      }
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Vui lòng kiểm tra kết nối internet và thử lại.';
    } else if (failure is CacheFailure) {
      return 'Lỗi lưu trữ dữ liệu cục bộ.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
    }
  }
}
