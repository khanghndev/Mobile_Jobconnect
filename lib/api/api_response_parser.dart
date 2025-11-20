import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';

class ApiResponseParser {
  static T parseObject<T>({
    required dynamic res,
    required T Function(Map<String, dynamic>) fromJson,
    required String errorMsg,
  }) {
    if (res is! Map<String, dynamic>) {
      throw ServerException(
        err: errorMsg,
        type: ServerExceptionType.api,
      );
    }
    return fromJson(res);
  }

  static List<T> parseList<T>({
    required dynamic res,
    required T Function(Map<String, dynamic>) fromJson,
    required String errorMsg,
  }) {
    if (res is! List) {
      throw ServerException(
        err: errorMsg,
        type: ServerExceptionType.api,
      );
    }
    return res.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  static Map<String, dynamic> parseMap({
    required dynamic res,
    required String errorMsg,
  }) {
    if (res is! Map<String, dynamic>) {
      throw ServerException(
        err: errorMsg,
        type: ServerExceptionType.api,
      );
    }
    return res;
  }

  /// Parse double từ response JSON
  static double parseDouble({
    required dynamic res,
    required String errorMsg,
  }) {
    if (res == null) {
      throw ServerException(
        err: errorMsg,
        type: ServerExceptionType.api,
      );
    }
    if (res is double) return res;
    if (res is int) return res.toDouble();
    if (res is String) {
      final d = double.tryParse(res);
      if (d != null) return d;
    }
    throw ServerException(
      err: errorMsg,
      type: ServerExceptionType.api,
    );
  }
}
