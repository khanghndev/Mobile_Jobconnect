import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/api_method.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';

class ApiService {
  final Map<String, String> defaultHeaders;

  ApiService({
    this.defaultHeaders = const {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  });

  // ========== PUBLIC METHODS ==========
  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      method: ApiMethod.get,
      endpoint: endpoint,
      queryParams: queryParams,
    );
  }

  Future<dynamic> post({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      method: ApiMethod.post,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
    );
  }

  Future<dynamic> put({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      method: ApiMethod.put,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
    );
  }

  Future<dynamic> patch({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      method: ApiMethod.patch,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
    );
  }

  Future<dynamic> delete({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    return _request(
      method: ApiMethod.delete,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
    );
  }

  // CORE REQUEST
  Future<dynamic> _request({
    required ApiMethod method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl + endpoint).replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );

    http.Response response;
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('\n===== 🌐 API REQUEST =====');
      debugPrint('➡️ METHOD: ${method.name.toUpperCase()}');
      debugPrint('📍 URL: $uri');
      debugPrint('📦 HEADERS: $defaultHeaders');
      if (queryParams != null && queryParams.isNotEmpty) {
        debugPrint('🔍 QUERY: $queryParams');
      }
      if (body != null) debugPrint('🧾 BODY: ${jsonEncode(body)}');

      switch (method) {
        case ApiMethod.get:
          response = await http.get(uri, headers: defaultHeaders);
          break;
        case ApiMethod.post:
          response = await http.post(uri, headers: defaultHeaders, body: _encodeBody(body));
          break;
        case ApiMethod.put:
          response = await http.put(uri, headers: defaultHeaders, body: _encodeBody(body));
          break;
        case ApiMethod.delete:
          response = await http.delete(uri, headers: defaultHeaders, body: _encodeBody(body));
          break;
        case ApiMethod.patch:
          response = await http.patch(uri, headers: defaultHeaders, body: _encodeBody(body));
          break;
      }

      stopwatch.stop();

      debugPrint('\n===== 📩 API RESPONSE =====');
      debugPrint('✅ STATUS: ${response.statusCode}');
      debugPrint('⏱️ TIME: ${stopwatch.elapsedMilliseconds} ms');
      debugPrint('📃 BODY: ${_shorten(response.body)}');
      debugPrint('=============================\n');

      return handleResponse(response, method);
    } on SocketException {
      throw ServerException(
        err: 'Không có kết nối Internet',
        type: ServerExceptionType.network,
      );
    } on TimeoutException {
      throw ServerException(
        err: 'Yêu cầu quá thời gian chờ',
        type: ServerExceptionType.timeout,
      );
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định: $e',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // ========== HELPERS ==========
  String _shorten(String body, {int maxLength = 500}) {
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength)}... (truncated)';
  }

  String? _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  dynamic handleResponse(http.Response response, ApiMethod method) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return response.statusCode;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    } else {
      String errorMessage = "Unknown error";

      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          if (body["message"] != null) {
            errorMessage = body["message"].toString();
          } else if (body["errors"] != null) {
            final errors = body["errors"] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              } else {
                errorMessage = firstError.toString();
              }
            }
          }
        }
      } catch (_) {
        errorMessage = response.body;
      }

      debugPrint('❌ API ERROR: $errorMessage');
      throw ServerException(
        err: 'Lỗi: $errorMessage',
        type: ServerExceptionType.api,
      );
    }
  }
}