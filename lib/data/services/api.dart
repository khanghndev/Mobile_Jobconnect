import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/dto/auth_dto/auth_login_dto.dart';
import 'package:job_connect/data/dto/auth_dto/auth_register_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dto/auth_dto/auth_response.dart';

class ApiService {
  final _client = http.Client();
  static const _keyToken = 'jwt_token';
  static const _keyLoggedIn = 'is_logged_in';

  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> get(String endpoint) async {
    final url = Uri.parse(baseUrl + endpoint);
    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      } else {
        // Nếu không phải danh sách, có thể là một đối tượng duy nhất
        // Chuyển đổi thành danh sách chứa một đối tượng
        return [decoded as Map<String, dynamic>];
      }
    } else if (response.statusCode == 204) {
      // Nếu không có nội dung (204 No Content), trả về danh sách rỗng
      return [];
    } else {
      return [];
    }
  }

  Future<int> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl + endpoint);
    print(url);
    print(data);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.statusCode;
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  Future<int> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl + endpoint);
    print(url);
    print(data);
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.statusCode;
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  Future<int> delete(String endpoint) async {
    final url = Uri.parse(baseUrl + endpoint);
    final response = await http.delete(url);
    print(url);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.statusCode;
    } else {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }

  /// Đăng ký người dùng mới
  Future<void> register(RegisterDto dto) async {
    final uri = Uri.parse(baseUrl + ApiConstants.registerEndpoint);
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (resp.statusCode != 200) {
      throw Exception('Đăng ký thất bại: ${resp.body}');
    }
  }

  /// Đăng nhập, trả về AuthResponse và lưu token + isLoggedIn
  Future<AuthResponse> login(LoginDto dto) async {
    final uri = Uri.parse(baseUrl + ApiConstants.loginEndpoint);
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final auth = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, auth.token);
      await prefs.setBool(_keyLoggedIn, true);

      return auth;
    } else {
      throw Exception('Đăng nhập thất bại: ${resp.body}');
    }
  }

  /// Đăng xuất: xóa token và đánh dấu không còn đăng nhập
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.setBool(_keyLoggedIn, false);
  }

  /// Kiểm tra xem user đã login chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Lấy JWT token đã lưu
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }
}
