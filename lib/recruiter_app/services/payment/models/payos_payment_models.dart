class CreatePayOsPaymentRequest {
  final String idUser;
  final String idPackage;
  final String? description;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerEmail;
  final String? returnUrl;
  final String? cancelUrl;

  CreatePayOsPaymentRequest({
    required this.idUser,
    required this.idPackage,
    this.description,
    this.buyerName,
    this.buyerPhone,
    this.buyerEmail,
    this.returnUrl,
    this.cancelUrl,
  });

  Map<String, dynamic> toJson() => {
        "idUser": idUser,
        "idPackage": idPackage,
        if (description != null) "description": description,
        if (buyerName != null) "buyerName": buyerName,
        if (buyerPhone != null) "buyerPhone": buyerPhone,
        if (buyerEmail != null) "buyerEmail": buyerEmail,
        if (returnUrl != null) "returnUrl": returnUrl,
        if (cancelUrl != null) "cancelUrl": cancelUrl,
      };
}

class CreatePayOsPaymentResponse {
  final int orderCode;
  final String paymentLinkId;
  final String checkoutUrl;
  final String? qrCode;
  final DateTime? expiredAt;
  final String? accountNumber;
  final String? accountName;
  final String? bin;

  CreatePayOsPaymentResponse({
    required this.orderCode,
    required this.paymentLinkId,
    required this.checkoutUrl,
    this.qrCode,
    this.expiredAt,
    this.accountNumber,
    this.accountName,
    this.bin,
  });

  factory CreatePayOsPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePayOsPaymentResponse(
      orderCode: json['orderCode'] is int
          ? json['orderCode']
          : int.tryParse(json['orderCode'].toString()) ?? 0,
      paymentLinkId: json['paymentLinkId']?.toString() ?? '',
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      qrCode: json['qrCode']?.toString(),
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'].toString())
          : null,
      accountNumber: json['accountNumber']?.toString(),
      accountName: json['accountName']?.toString(),
      bin: json['bin']?.toString(),
    );
  }
}

class PayOsReturnDto {
  final bool isSuccess;
  final bool isCancelled;
  final String code;
  final String status;
  final int? orderCode;
  final String? paymentLinkId;
  final String message;

  PayOsReturnDto({
    required this.isSuccess,
    required this.isCancelled,
    required this.code,
    required this.status,
    this.orderCode,
    this.paymentLinkId,
    required this.message,
  });

  factory PayOsReturnDto.fromJson(Map<String, dynamic> json) {
    return PayOsReturnDto(
      isSuccess: json['isSuccess'] ?? false,
      isCancelled: json['isCancelled'] ?? false,
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      orderCode: json['orderCode'] != null
          ? (json['orderCode'] is int
              ? json['orderCode']
              : int.tryParse(json['orderCode'].toString()))
          : null,
      paymentLinkId: json['paymentLinkId']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}

