import 'dart:io';
import 'package:flutter/foundation.dart';

class AppUtils {
  // Platform checks
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // Debug helpers
  static void debugPrint(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  static void debugLog(String tag, String message) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  // String utilities
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  static bool isNotNullOrEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncateString(
    String text,
    int maxLength, {
    String suffix = '...',
  }) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + suffix;
  }

  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone validation (Vietnam format)
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^(0|\+84)[3-9][0-9]{8}$').hasMatch(phone);
  }

  // Password validation
  static bool isValidPassword(String password) {
    // At least 6 characters, contains letter and number
    return password.length >= 6 &&
        RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password);
  }

  // Format number with thousand separators
  static String formatNumber(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  // Format currency (VND)
  static String formatCurrency(num amount) {
    return '${formatNumber(amount)}đ';
  }

  // Date formatting helpers
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/'
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.year}';
      default:
        return date.toString();
    }
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  // Time ago formatting
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (index) => chars[DateTime.now().millisecond % chars.length],
    ).join();
  }

  // Delay execution
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  // Remove Vietnamese accents
  static String removeVietnameseAccents(String text) {
    const vietnamese =
        'àáãạảăắằẳẵặâấầẩẫậèéẹẻẽêềếểễệđìíĩỉịòóõọỏôốồổỗộơớờởỡợùúũụủưứừửữựỳýỹỷỵÀÁÃẠẢĂẮẰẲẴẶÂẤẦẨẪẬÈÉẸẺẼÊỀẾỂỄỆĐÌÍĨỈỊÒÓÕỌỎÔỐỒỔỖỘƠỚỜỞỠỢÙÚŨỤỦƯỨỪỬỮỰỲÝỸỶỴ';
    const english =
        'aaaaaaaaaaaaaaaaeeeeeeeeeeediiiiiooooooooooooooooouuuuuuuuuuuyyyyyAAAAAAAAAAAAAAAAAEEEEEEEEEEEDIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY';

    String result = text;
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }
}
