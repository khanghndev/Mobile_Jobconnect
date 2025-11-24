import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/recruiter_app/services/payment/payos_payment_service.dart';
import 'package:job_connect/recruiter_app/services/payment/momo_payment_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentMethod; // 'payos' or 'momo'
  final String? orderCode; // For PayOS
  final String? orderId; // For MoMo
  final String? requestId; // For MoMo

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paymentMethod,
    this.orderCode,
    this.orderId,
    this.requestId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessingReturn = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkReturnUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkReturnUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi tải trang: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkReturnUrl(String url) {
    // Kiểm tra nếu URL là return URL từ PayOS hoặc MoMo
    if (url.contains(ApiConstants.payOsReturnEndpoint) ||
        url.contains(ApiConstants.momoReturnEndpoint)) {
      _handlePaymentReturn(url);
    }
  }

  Future<void> _handlePaymentReturn(String url) async {
    if (_isProcessingReturn) return;
    _isProcessingReturn = true;

    try {
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      if (widget.paymentMethod == 'payos') {
        await _handlePayOsReturn(queryParams);
      } else if (widget.paymentMethod == 'momo') {
        await _handleMomoReturn(queryParams);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý kết quả thanh toán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isProcessingReturn = false;
    }
  }

  Future<void> _handlePayOsReturn(Map<String, String> queryParams) async {
    try {
      final payOsService = PayOsPaymentService();
      final returnDto = await payOsService.handleReturn(
        code: queryParams['code'],
        paymentLinkId: queryParams['id'],
        cancel: queryParams['cancel'] == 'true',
        status: queryParams['status'],
        orderCode: widget.orderCode != null ? int.tryParse(widget.orderCode!) : null,
      );

      if (!mounted) return;

      if (returnDto.isSuccess) {
        // Thanh toán thành công
        Navigator.of(context).pop(true); // Return true để báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (returnDto.isCancelled) {
        // Người dùng hủy thanh toán
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã hủy thanh toán'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // Thanh toán thất bại
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thất bại: ${returnDto.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý thanh toán PayOS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleMomoReturn(Map<String, String> queryParams) async {
    try {
      final momoService = MomoPaymentService();
      final returnDto = await momoService.handleReturn(
        partnerCode: queryParams['partnerCode'],
        orderId: queryParams['orderId'] ?? widget.orderId,
        requestId: queryParams['requestId'] ?? widget.requestId,
        amount: queryParams['amount'] != null ? int.tryParse(queryParams['amount']!) : null,
        orderInfo: queryParams['orderInfo'],
        orderType: queryParams['orderType'],
        transId: queryParams['transId'] != null ? int.tryParse(queryParams['transId']!) : null,
        resultCode: queryParams['resultCode'] != null ? int.tryParse(queryParams['resultCode']!) : null,
        message: queryParams['message'],
        payType: queryParams['payType'],
        responseTime: queryParams['responseTime'] != null ? int.tryParse(queryParams['responseTime']!) : null,
        extraData: queryParams['extraData'],
        signature: queryParams['signature'],
      );

      if (!mounted) return;

      if (returnDto.isSuccess) {
        // Thanh toán thành công
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Thanh toán thất bại
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thất bại: ${returnDto.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý thanh toán MoMo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: recruiterPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(recruiterPrimary),
                    ),
                    SizedBox(height: 16.h),
                    const Text(
                      'Đang tải trang thanh toán...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

