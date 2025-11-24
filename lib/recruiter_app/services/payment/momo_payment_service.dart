import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/recruiter_app/services/payment/models/momo_payment_models.dart';

class MomoPaymentService {
  final ApiService _apiService;

  MomoPaymentService() : _apiService = ApiService();

  /// Tạo link thanh toán MoMo
  Future<CreateMomoPaymentResponse> createPayment({
    required String idUser,
    required String idPackage,
    String? orderInfo,
    String? lang,
    String? returnUrl,
    String? ipnUrl,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.momoCreatePaymentEndpoint,
        body: {
          "idUser": idUser,
          "idPackage": idPackage,
          if (orderInfo != null) "orderInfo": orderInfo,
          if (lang != null) "lang": lang,
          if (returnUrl != null) "returnUrl": returnUrl,
          if (ipnUrl != null) "ipnUrl": ipnUrl,
        },
        requireAuth: false,
      );

      if (res == null) {
        throw ServerException(
          err: 'API trả về null',
          type: ServerExceptionType.api,
        );
      }

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API MoMo',
          type: ServerExceptionType.api,
        );
      }

      return CreateMomoPaymentResponse.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi tạo thanh toán MoMo: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Xử lý return từ MoMo
  Future<MomoReturnDto> handleReturn({
    String? partnerCode,
    String? orderId,
    String? requestId,
    int? amount,
    String? orderInfo,
    String? orderType,
    int? transId,
    int? resultCode,
    String? message,
    String? payType,
    int? responseTime,
    String? extraData,
    String? signature,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (partnerCode != null) queryParams['partnerCode'] = partnerCode;
      if (orderId != null) queryParams['orderId'] = orderId;
      if (requestId != null) queryParams['requestId'] = requestId;
      if (amount != null) queryParams['amount'] = amount.toString();
      if (orderInfo != null) queryParams['orderInfo'] = orderInfo;
      if (orderType != null) queryParams['orderType'] = orderType;
      if (transId != null) queryParams['transId'] = transId.toString();
      if (resultCode != null) queryParams['resultCode'] = resultCode.toString();
      if (message != null) queryParams['message'] = message;
      if (payType != null) queryParams['payType'] = payType;
      if (responseTime != null) queryParams['responseTime'] = responseTime.toString();
      if (extraData != null) queryParams['extraData'] = extraData;
      if (signature != null) queryParams['signature'] = signature;

      final res = await _apiService.get(
        endpoint: ApiConstants.momoReturnEndpoint,
        queryParams: queryParams,
        requireAuth: false,
      );

      if (res == null || res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API MoMo return',
          type: ServerExceptionType.api,
        );
      }

      return MomoReturnDto.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi xử lý return MoMo: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}

