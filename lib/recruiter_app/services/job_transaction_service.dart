import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';

class JobTransactionService {
  final ApiService _apiService;

  JobTransactionService() : _apiService = ApiService();

  //TODO: Hàm nội bộ dùng chung để lấy danh sách job transaction
  Future<List<JobTransactionModel>> _fetchTransactionList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải là danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((e) => JobTransactionModel.fromJson(e as Map<String, dynamic>))
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

  //TODO: Lấy danh sách tất cả job transaction
  Future<List<JobTransactionModel>> getAllTransactions() async {
    return _fetchTransactionList(
      endpoint: ApiConstants.jobTransactionEndpoint,
      dataType: 'danh sách giao dịch',
    );
  }

  //TODO: Lấy danh sách job transaction theo userId
  Future<List<JobTransactionModel>> getTransactionsByUserId({
    required String userId,
  }) async {
    return _fetchTransactionList(
      endpoint: '${ApiConstants.jobTransactionEndpoint}/user/$userId',
      dataType: 'giao dịch theo user',
    );
  }

  //TODO: Lấy chi tiết job transaction theo id
  Future<JobTransactionModel?> getTransactionById({
    required String transactionId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.jobTransactionEndpoint}/$transactionId',
      );

      if (res == null) return null;

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết giao dịch)',
          type: ServerExceptionType.api,
        );
      }

      return JobTransactionModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Tạo mới job transaction
  Future<JobTransactionModel> createTransaction({
    required JobTransactionModel transaction,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.jobTransactionEndpoint,
        body: transaction.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo giao dịch)',
          type: ServerExceptionType.api,
        );
      }

      return JobTransactionModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật trạng thái giao dịch
  Future<void> updateTransactionStatus({
    required String transactionId,
    required String newStatus,
  }) async {
    try {
      await _apiService.patch(
        endpoint: '${ApiConstants.jobTransactionEndpoint}/$transactionId/status',
        body: {'status': newStatus},
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật trạng thái giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Xoá job transaction theo id
  Future<void> deleteTransaction({
    required String transactionId,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.jobTransactionEndpoint}/$transactionId',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xoá giao dịch: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}