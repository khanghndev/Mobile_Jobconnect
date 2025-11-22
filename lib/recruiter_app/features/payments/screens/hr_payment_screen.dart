import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/enum/job_transaction_status.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/features/job/service/job_transaction_service.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_method.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';
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

  bool _isLoading = true;
  String? _error;

  late UserModel _account;
  late SubscriptionPackageModel _package;
  late JobTransactionModel _jobTransaction;

  final List<PaymentMethod> _paymentMethods = [
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
    try {
      final now = DateTime.now();
      final jobTransaction = await _jobtransactionService.createTransaction(
        transaction: JobTransactionModel(
          idTransaction: '',
          idUser: widget.recruiterId,
          idPackage: _package.idPackage,
          amount: _package.price,
          paymentMethod: _paymentMethods.firstWhere((m) => m.isSelected).name,
          transactionDate: now,
          status: JobTransactionStatus.pending.name,
        ),
      );
      if (!mounted) return;
      setState(() {
        _jobTransaction = jobTransaction;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch thất bại'), backgroundColor: Colors.red),
      );
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
                Text(FormatUtils.formatCurrency(_package.price), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(TextTheme textTheme) {
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
                    border: Border.all(color: method.isSelected ? Colors.blue : Colors.grey.shade300, width: method.isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(method.icon, color: method.isSelected ? Colors.blue : Colors.grey[600], size: 22.sp),
                        SizedBox(width: 16.w),
                        Expanded(child: Text(method.name, style: textTheme.bodyMedium?.copyWith(fontWeight: method.isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 16.sp))),
                        if (method.isSelected) Icon(Icons.check_circle, color: Colors.blue, size: 20.sp),
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
              onPressed: () async {
                await _createTransaction();
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentConfirmationDetailScreen(idTransaction: _jobTransaction.idTransaction)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Thanh toán ngay', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white)),
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
