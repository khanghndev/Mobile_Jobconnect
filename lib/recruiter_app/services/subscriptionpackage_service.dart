import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/model/subscription_package_model.dart';

class SubscriptionPackageService {
  final ApiService _apiService;

  SubscriptionPackageService() : _apiService = ApiService();

  //  Hàm nội bộ lấy danh sách gói dịch vụ
  Future<List<SubscriptionPackageModel>> _fetchAllPackages({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res == null) return [];

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType)',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => SubscriptionPackageModel.fromJson(item as Map<String, dynamic>))
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

  //  Lấy tất cả gói dịch vụ (gọi hàm tổng)
  Future<List<SubscriptionPackageModel>> fetchSubscriptionPackages() async {
    return _fetchAllPackages(
      endpoint: ApiConstants.subscriptionPackageEndpoint,
      dataType: 'danh sách gói dịch vụ',
    );
  }

  //  Lấy chi tiết gói dịch vụ theo ID
  Future<SubscriptionPackageModel> fetchSubscriptionPackageById({
    required String packageId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.subscriptionPackageEndpoint}/$packageId',
      );

      if (res == null || res is! Map) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết gói dịch vụ)',
          type: ServerExceptionType.api,
        );
      }

      return SubscriptionPackageModel.fromJson(res as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết gói dịch vụ: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Kích hoạt gói dịch vụ sau khi quét mã thanh toán thành công
  Future<bool> activatePackage({
    required String packageId,
    required String transactionCode,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: '${ApiConstants.subscriptionPackageEndpoint}/activate',
        body: {
          'packageId': packageId,
          'transactionCode': transactionCode,
        },
      );

      // API chuẩn trả true hoặc message => chỉ cần kiểm tra có lỗi hay không
      return res != null;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi kích hoạt gói dịch vụ: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}