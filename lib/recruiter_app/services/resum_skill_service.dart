import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/resume/model/resume_skill_model.dart';

class ResumeSkillService {
  final ApiService _apiService;

  ResumeSkillService() : _apiService = ApiService();

  //  Hàm nội bộ dùng chung để lấy danh sách resume skill
  Future<List<ResumeSkillModel>> _fetchResumeSkillList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res == null) return [];

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải là danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => ResumeSkillModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Lấy toàn bộ kỹ năng trong hồ sơ
  Future<List<ResumeSkillModel>> getAllResumeSkills() async {
    return _fetchResumeSkillList(
      endpoint: ApiConstants.resumeSkillEndpoint,
      dataType: 'danh sách kỹ năng hồ sơ',
    );
  }

  //  Lấy danh sách kỹ năng theo resumeId (nếu cần lọc theo hồ sơ)
  Future<List<ResumeSkillModel>> getSkillsByResumeId({
    required String resumeId,
  }) async {
    return _fetchResumeSkillList(
      endpoint: '${ApiConstants.resumeSkillEndpoint}/resume/$resumeId',
      dataType: 'kỹ năng theo hồ sơ',
    );
  }
}