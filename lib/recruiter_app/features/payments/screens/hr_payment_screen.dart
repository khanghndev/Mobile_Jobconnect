import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/enum/job_transaction_status.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/features/job/service/job_transaction_service.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_method.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';
import 'package:job_connect/recruiter_app/services/payment/payos_payment_service.dart';
import 'package:job_connect/recruiter_app/services/payment/momo_payment_service.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_webview_screen.dart';
import 'hr_payment_confirmation_screen.dart';
import 'package:job_connect/features/mini_social/widgets/connect/groups_tab_shimmer.dart';

class HrPaymentScreen extends StatefulWidget {
  final String recruiterId;
  final SubscriptionPackageModel package;
  const HrPaymentScreen({
    super.key,
    required this.recruiterId,
    required this.package,
  });

  @override
  State<HrPaymentScreen> createState() => _HrPaymentScreenState();
}

class _HrPaymentScreenState extends State<HrPaymentScreen> {
  final UserService _accountService = UserService();
  final SubscriptionPackageService _subscriptionpackageService = SubscriptionPackageService();
  final JobTransactionService _jobtransactionService = JobTransactionService();
  final PayOsPaymentService _payOsPaymentService = PayOsPaymentService();
  final MomoPaymentService _momoPaymentService = MomoPaymentService();

  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _error;

  late UserModel _account;
  late SubscriptionPackageModel _package;
  late JobTransactionModel _jobTransaction;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'payos',
      name: 'PayOS',
      icon: Icons.payment,
      isSelected: false,
    ),
    PaymentMethod(
      id: 'momo',
      name: 'MoMo',
      icon: Icons.account_balance_wallet,
      isSelected: false,
    ),
    PaymentMethod(
      id: 'banking',
      name: 'Thanh toán nội bộ',
      icon: Icons.account_balance,
      isSelected: true,
    ),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _package = widget.package; // gán package ngay từ đầu
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final account = await _accountService.getUserById(id: widget.recruiterId);
      final package = await _subscriptionpackageService.fetchSubscriptionPackageById(
        packageId: widget.package.idPackage,
      );

      if (!mounted) return;
      setState(() {
        _account = account;
        _package = package;
        _nameController.text = account.userName;
        _phoneController.text = account.phoneNumber ?? "Chưa có số điện thoại";
        _emailController.text = account.email;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy dữ liệu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _createTransaction() async {
    final selectedMethod = _paymentMethods.firstWhere((m) => m.isSelected);
    
    // Xử lý thanh toán PayOS
    if (selectedMethod.id == 'payos') {
      await _processPayOsPayment();
      return;
    }
    
    // Xử lý thanh toán MoMo
    if (selectedMethod.id == 'momo') {
      await _processMomoPayment();
      return;
    }
    
    // Xử lý thanh toán nội bộ (banking)
    try {
      final now = DateTime.now();
      final jobTransaction = await _jobtransactionService.createTransaction(
        transaction: JobTransactionModel(
          idTransaction: '',
          idUser: widget.recruiterId,
          idPackage: _package.idPackage,
          amount: _package.price,
          paymentMethod: selectedMethod.name,
          transactionDate: now,
          status: JobTransactionStatus.pending.name,
        ),
      );
      if (!mounted) return;
      setState(() {
        _jobTransaction = jobTransaction;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationDetailScreen(idTransaction: _jobTransaction.idTransaction),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giao dịch thất bại: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _processPayOsPayment() async {
    if (_isProcessingPayment) return;
    
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Tạo return URL và cancel URL
      final baseUrl = ApiConstants.baseUrl;
      final returnUrl = '$baseUrl${ApiConstants.payOsReturnEndpoint}';
      final cancelUrl = '$baseUrl${ApiConstants.payOsReturnEndpoint}?cancel=true';

      // Tạo payment link từ PayOS
      final paymentResponse = await _payOsPaymentService.createPayment(
        idUser: widget.recruiterId,
        idPackage: _package.idPackage,
        description: 'Thanh toán gói ${_package.packageName}',
        buyerName: _account.userName,
        buyerPhone: _account.phoneNumber,
        buyerEmail: _account.email,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      if (!mounted) return;

      // Mở URL thanh toán trong WebView
      final checkoutUrl = paymentResponse.checkoutUrl;
      if (checkoutUrl.isNotEmpty) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: checkoutUrl,
              paymentMethod: 'payos',
              orderCode: paymentResponse.orderCode.toString(),
            ),
          ),
        );

        if (!mounted) return;

        // Nếu thanh toán thành công, chỉ hiển thị thông báo và quay về
        if (result == true) {
          if (!mounted) return;
          // Hiển thị thông báo thành công (đã được hiển thị trong WebView)
          // Quay về màn hình trước đó
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Không nhận được link thanh toán từ PayOS');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán PayOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _processMomoPayment() async {
    if (_isProcessingPayment) return;
    
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Tạo return URL và IPN URL
      final baseUrl = ApiConstants.baseUrl;
      final returnUrl = '$baseUrl${ApiConstants.momoReturnEndpoint}';
      final ipnUrl = '$baseUrl/api/Momo/ipn';

      // Tạo payment link từ MoMo
      final paymentResponse = await _momoPaymentService.createPayment(
        idUser: widget.recruiterId,
        idPackage: _package.idPackage,
        orderInfo: 'Thanh toán gói ${_package.packageName}',
        lang: 'vi',
        returnUrl: returnUrl,
        ipnUrl: ipnUrl,
      );

      if (!mounted) return;

      // Ưu tiên sử dụng deeplink nếu có, nếu không thì dùng payUrl
      final paymentUrl = paymentResponse.deeplink ?? paymentResponse.payUrl;
      
      if (paymentUrl.isNotEmpty) {
        // Nếu có deeplink, thử mở app MoMo, nếu không thì mở WebView
        if (paymentResponse.deeplink != null && paymentResponse.deeplink!.isNotEmpty) {
          // Thử mở deeplink (có thể mở app MoMo)
          try {
            final uri = Uri.parse(paymentResponse.deeplink!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              // Nếu mở được app MoMo, hiển thị thông báo và quay về
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã mở ứng dụng MoMo. Vui lòng hoàn tất thanh toán trong app.'),
                  duration: Duration(seconds: 3),
                ),
              );
              // Quay về màn hình trước
              Navigator.of(context).pop();
              return;
            }
          } catch (e) {
            // Nếu không mở được app, fallback về WebView
          }
        }
        
        // Mở WebView với payUrl
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: paymentResponse.payUrl,
              paymentMethod: 'momo',
              orderId: paymentResponse.orderId,
              requestId: paymentResponse.requestId,
            ),
          ),
        );

        if (!mounted) return;

        // Nếu thanh toán thành công, chỉ hiển thị thông báo và quay về
        if (result == true) {
          if (!mounted) return;
          // Hiển thị thông báo thành công (đã được hiển thị trong WebView)
          // Quay về màn hình trước đó
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Không nhận được link thanh toán từ MoMo');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán MoMo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _selectPaymentMethod(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method.isSelected = method.id == id;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: 'Xác nhận thanh toán'),
      body: SafeArea(
        child: _isLoading
            ? GroupsTabShimmer()
            : _error != null
                ? Center(
                    child: BackgroundErrorState(
                      title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                      onRetry: _fetchData,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildServiceSummary(textTheme),
                              SizedBox(height: 24.h),
                              _buildPaymentMethodsSection(textTheme),
                              SizedBox(height: 24.h),
                              _buildBillingDetailsSection(textTheme),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomBar(textTheme),
                    ],
                  ),
      ),
    );
  }

  Widget _buildServiceSummary(TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dịch vụ đã chọn', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(Icons.spa, color: Colors.blue, size: 20),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_package.packageName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16.sp)),
                      SizedBox(height: 4.h),
                      Text('${_package.durationDays} ngày', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 12.sp)),
                    ],
                  ),
                ),
                Text(FormatUtils.formatCurrency(_package.price), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
            Divider(height: 24.h, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng cộng', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Text(
                  FormatUtils.formatCurrency(_package.price),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: const Color(0xFF1A237E), // recruiterPrimary
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(TextTheme textTheme) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF3949AB);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phương thức thanh toán', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            ..._paymentMethods.map((method) {
              return InkWell(
                onTap: () => _selectPaymentMethod(method.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: method.isSelected ? recruiterPrimary : Colors.grey.shade300,
                      width: method.isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: method.isSelected
                        ? LinearGradient(
                            colors: [
                              recruiterPrimary.withValues(alpha: 0.1),
                              recruiterSecondary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: method.isSelected ? null : Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          method.icon,
                          color: method.isSelected ? recruiterPrimary : Colors.grey[600],
                          size: 22.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            method.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: method.isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16.sp,
                              color: method.isSelected ? recruiterPrimary : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (method.isSelected)
                          Icon(Icons.check_circle, color: recruiterPrimary, size: 20.sp),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingDetailsSection(TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin khách hàng', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _buildTextField(label: 'Họ và tên', hint: 'Nhập họ và tên', controller: _nameController, readOnly: true),
            _buildTextField(label: 'Số điện thoại', hint: 'Nhập số điện thoại', controller: _phoneController, readOnly: true, keyboardType: TextInputType.phone),
            _buildTextField(label: 'Email', hint: 'Nhập email', controller: _emailController, readOnly: true, keyboardType: TextInputType.emailAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              label: label.isEmpty ? null : Text(label),
              hintStyle: TextStyle(color: Colors.red[400], fontSize: 10.sp),
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _isProcessingPayment ? null : () async {
                await _createTransaction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E), // recruiterPrimary
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                disabledBackgroundColor: Colors.grey,
                elevation: 2,
              ),
              child: _isProcessingPayment
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Thanh toán ngay', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white)),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tổng thanh toán', style: textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 14.sp)),
                  SizedBox(height: 4.h),
                  Text(FormatUtils.formatCurrency(_package.price), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
