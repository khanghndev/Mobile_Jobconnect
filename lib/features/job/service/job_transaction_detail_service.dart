import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_transaction_detail_model.dart';

class JobTransactionDetailService {
  final ApiService _apiService;

  JobTransactionDetailService() : _apiService = ApiService();

  //  Lấy chi tiết giao dịch theo transactionDetailId
  Future<JobTransactionDetailModel> getJobTransactionDetail({
    required String transactionDetailId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.jobTransactionDetailEndpoint}/$transactionDetailId',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết giao dịch)',
          type: ServerExceptionType.api,
        );
      }

      return JobTransactionDetailModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Tạo mới chi tiết giao dịch
  Future<JobTransactionDetailModel> createJobTransactionDetail({
    required JobTransactionDetailModel detail,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.jobTransactionDetailEndpoint,
        body: detail.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo chi tiết giao dịch)',
          type: ServerExceptionType.api,
        );
      }

      return JobTransactionDetailModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo chi tiết giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Cập nhật chi tiết giao dịch
  Future<JobTransactionDetailModel> updateJobTransactionDetail({
    required String transactionDetailId,
    required JobTransactionDetailModel detail,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.jobTransactionDetailEndpoint}/$transactionDetailId',
        body: detail.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật chi tiết giao dịch)',
          type: ServerExceptionType.api,
        );
      }

      return JobTransactionDetailModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật chi tiết giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Xoá chi tiết giao dịch theo transactionDetailId
  Future<void> deleteJobTransactionDetail({
    required String transactionDetailId,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.jobTransactionDetailEndpoint}/$transactionDetailId',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xoá chi tiết giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}
