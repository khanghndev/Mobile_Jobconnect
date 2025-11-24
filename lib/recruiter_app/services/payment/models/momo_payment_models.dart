class CreateMomoPaymentRequest {
  final String idUser;
  final String idPackage;
  final String? orderInfo;
  final String? lang;
  final String? returnUrl;
  final String? ipnUrl;

  CreateMomoPaymentRequest({
    required this.idUser,
    required this.idPackage,
    this.orderInfo,
    this.lang,
    this.returnUrl,
    this.ipnUrl,
  });

  Map<String, dynamic> toJson() => {
        "idUser": idUser,
        "idPackage": idPackage,
        if (orderInfo != null) "orderInfo": orderInfo,
        if (lang != null) "lang": lang,
        if (returnUrl != null) "returnUrl": returnUrl,
        if (ipnUrl != null) "ipnUrl": ipnUrl,
      };
}

class CreateMomoPaymentResponse {
  final String payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final String orderId;
  final String requestId;

  CreateMomoPaymentResponse({
    required this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    required this.orderId,
    required this.requestId,
  });

  factory CreateMomoPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreateMomoPaymentResponse(
      payUrl: json['payUrl']?.toString() ?? '',
      deeplink: json['deeplink']?.toString(),
      qrCodeUrl: json['qrCodeUrl']?.toString(),
      orderId: json['orderId']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
    );
  }
}

class MomoReturnDto {
  final bool isSuccess;
  final int resultCode;
  final String message;
  final String orderId;
  final String requestId;

  MomoReturnDto({
    required this.isSuccess,
    required this.resultCode,
    required this.message,
    required this.orderId,
    required this.requestId,
  });

  factory MomoReturnDto.fromJson(Map<String, dynamic> json) {
    return MomoReturnDto(
      isSuccess: json['isSuccess'] ?? false,
      resultCode: json['resultCode'] is int
          ? json['resultCode']
          : int.tryParse(json['resultCode'].toString()) ?? -1,
      message: json['message']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
    );
  }
}

