import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/api_method.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Map<String, String> defaultHeaders;
  final http.Client _httpClient;

  ApiService({
    this.defaultHeaders = const {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  }) : _httpClient = _createHttpClient();

  // Factory method để tạo HttpClient
  static http.Client _createHttpClient() {
    // Cấu hình HttpClient để xử lý self-signed certificate (chỉ trong debug mode)
    if (kDebugMode) {
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Trong debug mode, chấp nhận tất cả certificates (bao gồm self-signed)
          return true;
        };
      return IOClient(httpClient);
    } else {
      // Trong production, sử dụng client mặc định với certificate verification
      return http.Client();
    }
  }

  // PUBLIC METHODS (đã thêm requireAuth)

  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    return _request(
      method: ApiMethod.get,
      endpoint: endpoint,
      queryParams: queryParams,
      requireAuth: requireAuth,
    );
  }

  Future<dynamic> post({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    return _request(
      method: ApiMethod.post,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
      requireAuth: requireAuth,
    );
  }

  Future<dynamic> put({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    return _request(
      method: ApiMethod.put,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
      requireAuth: requireAuth,
    );
  }

  Future<dynamic> patch({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    return _request(
      method: ApiMethod.patch,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
      requireAuth: requireAuth,
    );
  }

  Future<dynamic> delete({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    return _request(
      method: ApiMethod.delete,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
      requireAuth: requireAuth,
    );
  }

  // CORE REQUEST 

  Future<dynamic> _request({
    required ApiMethod method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requireAuth = false,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl + endpoint).replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );

    // AUTH TOKEN
    String? token;
    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      SharedPrefsService prefsService = SharedPrefsService(prefs: prefs);
      token = prefsService.getString(SharedPrefsKey.token);
      if (token == null || token.isEmpty) {
        throw ServerException(
          err: 'Bạn chưa đăng nhập hoặc token đã hết hạn.',
          type: ServerExceptionType.unauthorized,
        );
      }
    }

    // HEADERS
    final headers = Map<String, String>.from(defaultHeaders);
    if (requireAuth) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    final stopwatch = Stopwatch()..start();

    try {
      // REQUEST LOG
      debugPrint('\n===== 🌐 API REQUEST =====');
      debugPrint('➡️ METHOD: ${method.name.toUpperCase()}');
      debugPrint('📍 URL: $uri');
      debugPrint('📦 HEADERS: $headers');
      if (queryParams != null) debugPrint('🔍 QUERY: $queryParams');
      if (body != null) debugPrint('🧾 BODY: ${jsonEncode(body)}');

      // EXECUTE METHOD
      switch (method) {
        case ApiMethod.get:
          response = await _httpClient.get(uri, headers: headers);
          break;
        case ApiMethod.post:
          response = await _httpClient.post(uri, headers: headers, body: _encodeBody(body));
          break;
        case ApiMethod.put:
          response = await _httpClient.put(uri, headers: headers, body: _encodeBody(body));
          break;
        case ApiMethod.patch:
          response = await _httpClient.patch(uri, headers: headers, body: _encodeBody(body));
          break;
        case ApiMethod.delete:
          response = await _httpClient.delete(uri, headers: headers, body: _encodeBody(body));
          break;
      }

      stopwatch.stop();

      // RESPONSE LOG
      debugPrint('\n===== 📩 API RESPONSE =====');
      debugPrint('✅ STATUS: ${response.statusCode}');
      debugPrint('⏱️ TIME: ${stopwatch.elapsedMilliseconds} ms');
      debugPrint('📃 BODY: ${_shorten(response.body)}');
      debugPrint('=============================\n');

      return handleResponse(response, method);

    } catch (e) {
      if (e is SocketException) {
        throw ServerException(err: 'Không có kết nối Internet', type: ServerExceptionType.network);
      }
      if (e is TimeoutException) {
        throw ServerException(err: 'Quá thời gian chờ', type: ServerExceptionType.timeout);
      }
      // Xử lý lỗi SSL Certificate
      if (e.toString().contains('CERTIFICATE_VERIFY_FAILED') || 
          e.toString().contains('HandshakeException')) {
        throw ServerException(
          err: 'Lỗi xác thực SSL: Server đang sử dụng chứng chỉ tự ký. Vui lòng liên hệ quản trị viên.',
          type: ServerExceptionType.network,
        );
      }
      throw ServerException(err: 'Lỗi không xác định: $e', type: ServerExceptionType.unknown);
    }
  }

  // HELPERS

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
    // Kiểm tra Content-Type để phát hiện HTML response
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    final isHtml = contentType.contains('text/html') || 
                   response.body.trim().toLowerCase().startsWith('<!doctype') ||
                   response.body.trim().toLowerCase().startsWith('<html');

    if (isHtml) {
      // Phát hiện HTML response (có thể là portal redirect, error page, etc.)
      debugPrint('⚠️ API trả về HTML thay vì JSON - có thể là redirect hoặc error page');
      throw ServerException(
        err: 'Server trả về HTML thay vì JSON. Có thể do lỗi kết nối mạng hoặc server đang bảo trì.',
        type: ServerExceptionType.network,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return response.statusCode;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // Nếu không parse được JSON, có thể là HTML hoặc text khác
        if (response.body.trim().toLowerCase().startsWith('<')) {
          throw ServerException(
            err: 'Server trả về HTML thay vì JSON. Vui lòng kiểm tra kết nối mạng.',
            type: ServerExceptionType.network,
          );
        }
        return response.body;
      }
    }

    // Error response
    String errorMessage = "Unknown error";
    try {
      // Kiểm tra xem có phải HTML không
      if (response.body.trim().toLowerCase().startsWith('<')) {
        throw ServerException(
          err: 'Server trả về HTML thay vì JSON. Có thể do lỗi kết nối mạng hoặc server đang bảo trì.',
          type: ServerExceptionType.network,
        );
      }

      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body["message"] != null) {
          errorMessage = body["message"];
        } else if (body["errors"] != null && body["errors"] is Map<String, dynamic>) {
          final first = (body["errors"] as Map).values.first;
          errorMessage = first is List ? first.first.toString() : first.toString();
        }
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      // Nếu response body quá dài (có thể là HTML), chỉ lấy phần đầu
      if (response.body.length > 200) {
        errorMessage = '${response.body.substring(0, 200)}...';
      } else {
        errorMessage = response.body;
      }
    }

    debugPrint('❌ API ERROR: $errorMessage');

    throw ServerException(
      err: 'Lỗi: $errorMessage',
      type: ServerExceptionType.api,
    );
  }

  // Dispose httpClient khi không dùng nữa
  void dispose() {
    _httpClient.close();
  }
}
