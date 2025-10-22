import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_info_customer_form.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_bottom_bar.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_method.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_service_seleted.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'credit_card',
      name: 'Thẻ tín dụng / Ghi nợ',
      icon: Icons.credit_card,
      isSelected: true,
    ),
    PaymentMethod(
      id: 'momo',
      name: 'Ví MoMo',
      icon: Icons.account_balance_wallet,
    ),
    PaymentMethod(
      id: 'banking',
      name: 'Chuyển khoản ngân hàng',
      icon: Icons.account_balance,
    ),
  ];

  final List<ServiceItem> _selectedServices = [
    ServiceItem(
      name: 'Gói Kết nối Chuyên nghiệp',
      price: 1200000,
      duration: '30 ngày',
      icon: Icons.star_border,
    ),
    ServiceItem(
      name: 'Hỗ trợ Ưu tiên 24/7',
      price: 800000,
      duration: '15 ngày',
      icon: Icons.headset_mic,
    ),
  ];

  int get _totalAmount => _selectedServices.fold(0, (sum, item) => sum + item.price);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      SnackbarApp.show(
        context,
        title: 'Thất bại',
        message: "Vui lòng điền đầy đủ thông tin khách hàng",
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }

    // Lấy phương thức thanh toán đang chọn
    final selectedMethod = _paymentMethods.firstWhere((method) => method.isSelected);

    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text('Đang xử lý thanh toán bằng ${selectedMethod.name}...'),
          ],
        ),
      ),
    );
    context.pop();
    bool paymentSuccess = true;

    if (paymentSuccess) {
      SnackbarApp.show(
        context,
        title: 'Thành công',
        message: 'Thanh toán ${FormatUtils.formatCurrency(_totalAmount * 1.0)} đ thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Thanh toán"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServicesSummaryWidget(
                      selectedServices: _selectedServices,
                      totalAmount: _totalAmount * 1.0,
                    ),
                    SizedBox(height: 24.h),
                    PaymentMethods(
                      paymentMethods: _paymentMethods,
                      isDarkMode: Theme.of(context).brightness == Brightness.dark,
                      onSelect: (id) {
                        setState(() {
                          for (var method in _paymentMethods) {
                            method.isSelected = method.id == id;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 24.h),
                    PaymentInfoCustomerForm(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                      formKey: _formKey,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PaymentBottomBar(
        totalAmount: _totalAmount * 1.0,
        onPayment: _processPayment,
      ),
    );
  }
}