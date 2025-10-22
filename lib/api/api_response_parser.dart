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
}