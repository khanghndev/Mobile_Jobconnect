import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  Future<dynamic> get({required String endpoint}) async {
    return _request(
      method: ApiMethod.get,
      endpoint: endpoint,
    );
  }

  Future<dynamic> post({required String endpoint,required dynamic body}) async {
    return _request(
      method: ApiMethod.post,
      endpoint: endpoint,
      body: body,
    );
  }

  Future<dynamic> put({required String endpoint,required dynamic body}) async {
    return _request(
      method: ApiMethod.put,
      endpoint: endpoint,
      body: body,
    );
  }

  Future<dynamic> delete({required String endpoint}) async {
    return _request(
      method: ApiMethod.delete,
      endpoint: endpoint,
    );
  }

  Future<dynamic> _request({
    required ApiMethod method,
    required String endpoint,
    dynamic body,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    http.Response response;

    try {
      switch (method) {
        case ApiMethod.get:
          response = await http.get(url, headers: defaultHeaders);
          break;
        case ApiMethod.post:
          response = await http.post(
            url,
            headers: defaultHeaders,
            body: _encodeBody(body),
          );
          break;
        case ApiMethod.put:
          response = await http.put(
            url,
            headers: defaultHeaders,
            body: _encodeBody(body),
          );
          break;
        case ApiMethod.delete:
          response = await http.delete(url, headers: defaultHeaders);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      return handleResponse(response, method);
    } on SocketException {
      throw ServerException(
        err: 'No Internet connection',
        type: ServerExceptionType.network,
      );
    } on TimeoutException {
      throw ServerException(
        err: 'Request timeout',
        type: ServerExceptionType.timeout,
      );
    } catch (e) {
      throw ServerException(
        err: 'Unexpected error: $e',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Encode body phù hợp: Map, List, String hoặc null
  String? _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body; // raw string
    return jsonEncode(body); // Map/List/Object
  }

  dynamic handleResponse(http.Response response, ApiMethod method) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return response.statusCode; // trả về status nếu không có body
      }
      try {
        return jsonDecode(response.body); // Map hoặc List
      } catch (_) {
        return response.body; // fallback raw string
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
        errorMessage = response.body; // fallback nếu không parse được
      }

      throw ServerException(
        err: '$method failed: ${response.statusCode} - $errorMessage',
        type: ServerExceptionType.api,
      );
    }
  }
}
