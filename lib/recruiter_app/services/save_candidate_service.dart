import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/model/save_candidate_model.dart';

class SaveCandidateService {
  final ApiService _apiService;

  SaveCandidateService() : _apiService = ApiService();

  //TODO: Lấy danh sách ứng viên đã lưu theo recruiterId (lọc client-side)
  Future<List<SaveCandidateModel>> getSavedCandidates({
    required String recruiterId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: ApiConstants.saveCandidateEndpoint,
      );

      if (res == null) return [];

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (danh sách ứng viên đã lưu)',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => SaveCandidateModel.fromJson(item as Map<String, dynamic>))
          .where((e) => e.idUserRecruiter == recruiterId)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải danh sách ứng viên đã lưu: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Lưu ứng viên mới (Save Candidate)
  Future<void> saveCandidate({
    required SaveCandidateModel data,
  }) async {
    try {
      await _apiService.post(
        endpoint: ApiConstants.saveCandidateEndpoint,
        body: data,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi lưu ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật ghi chú (note) cho ứng viên đã lưu
  Future<void> updateCandidate({
    required SaveCandidateModel candidate,
  }) async {
    try {
      await _apiService.put(
        endpoint:
            '${ApiConstants.saveCandidateEndpoint}/${candidate.idUserRecruiter}/${candidate.idUserCandidate}',
        body: candidate.toJson(),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật thông tin ứng viên: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Xóa ứng viên đã lưu theo recruiterId & candidateId
  Future<void> deleteCandidate({
    required String recruiterId,
    required String candidateId,
  }) async {
    try {
      await _apiService.delete(
        endpoint:
            '${ApiConstants.saveCandidateEndpoint}/$recruiterId/$candidateId',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa ứng viên đã lưu: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}
