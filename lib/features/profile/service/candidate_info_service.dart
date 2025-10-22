import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';

class CandidateInfoService {
  final ApiService _apiService;

  CandidateInfoService() : _apiService = ApiService();

  // TODO: Lấy danh sách tất cả ứng viên
  Future<List<CandidateInfoModel>> getAllCandidates() async {
    try {
      final res = await _apiService.get(
        endpoint: ApiConstants.candidateInfoEndpoint,
      );

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (danh sách ứng viên)',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((e) => CandidateInfoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải danh sách ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Lấy thông tin ứng viên theo ID
  Future<CandidateInfoModel> getCandidateById({required String id}) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.candidateInfoEndpoint}/$id',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết ứng viên)',
          type: ServerExceptionType.api,
        );
      }

      return CandidateInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Tạo ứng viên mới
  Future<CandidateInfoModel> createCandidate(CandidateInfoModel candidate) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.candidateInfoEndpoint,
        body: candidate.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo ứng viên)',
          type: ServerExceptionType.api,
        );
      }

      return CandidateInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo ứng viên mới: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Cập nhật thông tin ứng viên
  Future<CandidateInfoModel> updateCandidate({
    required String id,
    required CandidateInfoModel candidate,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.candidateInfoEndpoint}/$id',
        body: {
          "idUser": candidate.idUser,
          "workPosition": candidate.workPosition,
          "ratingScore": candidate.ratingScore,
          "universityName": candidate.universityName,
          "educationLevel": candidate.educationLevel,
          "experienceYears": candidate.experienceYears,
          "skills": candidate.skills,
        },
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật ứng viên)',
          type: ServerExceptionType.api,
        );
      }

      return CandidateInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Xóa ứng viên
  Future<void> deleteCandidate({required String id}) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.candidateInfoEndpoint}/$id',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Tìm kiếm ứng viên theo từ khóa (tuỳ chọn nếu API có hỗ trợ)
  Future<List<CandidateInfoModel>> searchCandidates(String keyword) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.candidateInfoEndpoint}?search=$keyword',
      );

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tìm kiếm ứng viên)',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((e) => CandidateInfoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tìm kiếm ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}