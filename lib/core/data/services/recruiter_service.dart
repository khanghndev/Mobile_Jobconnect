import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/recruiter_info_model.dart';

class RecruiterService {
  final _client = http.Client();

  /// Lấy thông tin recruiter theo userId, cần truyền token đã lưu
  Future<RecruiterInfo> fetchByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception('Chưa có token, vui lòng đăng nhập lại.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.recruiterInfoEndpoint}/$userId',
    );
    final resp = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(resp.body);
      return RecruiterInfo.fromJson(data);
    } else if (resp.statusCode == 404) {
      throw Exception('Không tìm thấy recruiter với id: $userId');
    } else {
      throw Exception(
        'Lấy thông tin recruiter thất bại: [${resp.statusCode}] ${resp.body}',
      );
    }
  }
}
