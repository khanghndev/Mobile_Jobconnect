import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/recruiter_app/services/payment/models/payos_payment_models.dart';

class PayOsPaymentService {
  final ApiService _apiService;

  PayOsPaymentService() : _apiService = ApiService();

  /// Tạo link thanh toán PayOS
  Future<CreatePayOsPaymentResponse> createPayment({
    required String idUser,
    required String idPackage,
    String? description,
    String? buyerName,
    String? buyerPhone,
    String? buyerEmail,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.payOsCreatePaymentEndpoint,
        body: {
          "idUser": idUser,
          "idPackage": idPackage,
          if (description != null) "description": description,
          if (buyerName != null) "buyerName": buyerName,
          if (buyerPhone != null) "buyerPhone": buyerPhone,
          if (buyerEmail != null) "buyerEmail": buyerEmail,
          if (returnUrl != null) "returnUrl": returnUrl,
          if (cancelUrl != null) "cancelUrl": cancelUrl,
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
          err: 'Phản hồi không hợp lệ từ API PayOS',
          type: ServerExceptionType.api,
        );
      }

      return CreatePayOsPaymentResponse.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi tạo thanh toán PayOS: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Xử lý return từ PayOS
  Future<PayOsReturnDto> handleReturn({
    String? code,
    String? paymentLinkId,
    bool? cancel,
    String? status,
    int? orderCode,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (code != null) queryParams['code'] = code;
      if (paymentLinkId != null) queryParams['id'] = paymentLinkId;
      if (cancel != null) queryParams['cancel'] = cancel.toString();
      if (status != null) queryParams['status'] = status;
      if (orderCode != null) queryParams['orderCode'] = orderCode.toString();

      final res = await _apiService.get(
        endpoint: ApiConstants.payOsReturnEndpoint,
        queryParams: queryParams,
        requireAuth: false,
      );

      if (res == null || res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API PayOS return',
          type: ServerExceptionType.api,
        );
      }

      return PayOsReturnDto.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi xử lý return PayOS: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}

