// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/job_transaction_status.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/features/payments/widgets/payment/payment_method.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/job_transaction_service.dart';
import '../../../services/subscriptionpackage_service.dart';
import 'hr_payment_confirmation_screen.dart';

// ignore: must_be_immutable
class HrPaymentScreen extends StatefulWidget {
  String idBank;
  double balance;
  String recruiterId;
  SubscriptionPackageModel package;
  HrPaymentScreen({
    super.key,
    required this.idBank,
    required this.balance,
    required this.recruiterId,
    required this.package,
  });

  @override
  State<HrPaymentScreen> createState() => _HrPaymentScreenState();
}

class _HrPaymentScreenState extends State<HrPaymentScreen> {
  //Khởi tạo service
  final UserService _accountService = UserService();
  final SubscriptionPackageService _subscriptionpackageService = SubscriptionPackageService();
  final JobTransactionService _jobtransactionService = JobTransactionService();
  // Biến lưu trạng thái
  bool _isLoading = true;
  String? _error;
  // Biến lưu thông tin tài khoản
  late UserModel _account;  
  late SubscriptionPackageModel _package;
  late JobTransactionModel _jobTransaction; // Biến lưu thông tin giao dịch

  // Danh sách các phương thức thanh toán
  final List<PaymentMethod> _paymentMethods = [
     PaymentMethod(
      id: 'banking', 
      name: 'Thanh toán nội bộ', 
      icon: Icons.account_balance,
      isSelected: true,
    ),
    // PaymentMethod(
    //   id: 'vn_pay', 
    //   name: 'VN Pay', 
    //   icon: Icons.qr_code_scanner,
    //   isSelected: false,
    // ),
    // PaymentMethod(
    //   id: 'zalo_pay', 
    //   name: 'Zalo Pay', 
    //   icon: Icons.savings,
    //   isSelected: false,
    // ),
    // PaymentMethod(
    //   id: 'momo', 
    //   name: 'Ví MoMo', 
    //   icon: Icons.account_balance_wallet,
    //   isSelected: false,
    // ),
  ];

  // Chọn phuơng thức thanh toán
  void _selectPaymentMethod(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method.isSelected = method.id == id;
      }
    });
  }

  // Lấy toàn bộ dữ liệu 
  Future<void> _fetchData() async {
    try {
      // Lấy thông tin tài khoản
      final account = await _accountService.getUserById(id:widget.recruiterId);
      // Lấy gói dịch vụ
      final package = await _subscriptionpackageService.fetchSubscriptionPackageById(packageId: widget.package.idPackage);
      if (!mounted) return;
      setState(() {
        _account = account;
        _package = package;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy dữ liệu: $e'), backgroundColor: Colors.red,),
      );
    }
  }

  // Hàm tạp giao dịch mới và lưu về CSDL
  Future<void> _createTransaction() async {
    try {
      // Lấy ngày giờ
      final now = DateTime.now();
      // Tạo giao dịch mới
      final jobTransaction = await _jobtransactionService.createTransaction(
        transaction:  JobTransactionModel(
          idTransaction: '', // Tạo id tự động
          idUser: widget.recruiterId,
          idPackage: _package.idPackage,
          amount: _package.price,
          paymentMethod: _paymentMethods.firstWhere((method) => method.isSelected).name,
          transactionDate: now,
          status: JobTransactionStatus.pending.name, // ban đầu ở pending, xác nhận thành accepted
        ),
      );
      if (!mounted) return;
      setState(() {
        _jobTransaction = jobTransaction;
        _isLoading = false;
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giao dịch thất bại'), backgroundColor: Colors.red,),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Kiểm tra lỗi
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thanh toán")),
        body: Center(child: Text("Lỗi: $_error")),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Tiêu đề
      appBar: AppBar(
        elevation: 0,
        title: const Text("Thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      // Nội dung
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DỊch vụ đã chọn
                      _buildServicesSummary(),
                      const SizedBox(height: 24),
                      // Phương thức thanh toán
                      _buildPaymentMethodsSection(),
                      const SizedBox(height: 24),
                      // Thông tin khách hàng
                      _buildBillingDetailsSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // Tóm tắt dịch vụ đã chọn
  Widget _buildServicesSummary() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dịch vụ đã chọn',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(1, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.blue.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _package.packageName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_package.durationDays} ngày',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatCurrency(_package.price)} đ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatCurrency(_package.price)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách các phương thức thanh toán
  Widget _buildPaymentMethodsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách các phương thức thanh toán
            ...List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              return InkWell(
                onTap: () => _selectPaymentMethod(method.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: method.isSelected ? Colors.blue : Colors.grey.shade300,
                      width: method.isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(method.icon, color: method.isSelected ? Colors.blue : Colors.grey[600]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            method.name,
                            style: TextStyle(
                              fontWeight: method.isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (method.isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                          ),
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
  
  // Thông tin khách hàng
  Widget _buildBillingDetailsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Họ và tên',
              hint: 'Nhập họ và tên của bạn',
              prefixIcon: Icons.person,
              keyboardType: TextInputType.name,
              initialValue: _account.userName,
              readOnly: true,
            ),
            _buildTextField(
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại của bạn',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              initialValue: _account.phoneNumber,
              readOnly: true,
            ),
            _buildTextField(
              label: 'Email',
              hint: 'Nhập địa chỉ email của bạn',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              initialValue: _account.email,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
  
  // Trường nhập liệu
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
    bool readOnly = false,
  }) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _ctrl = TextEditingController(text: initialValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(prefixIcon, size: 20),
              filled: true,
              fillColor: Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Nút thanh toán
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Tạo giao dịch mới với trạng thái là "pending"
                await _createTransaction();
                await Future.delayed(const Duration(seconds: 1));
                // Qua trang xác nhận thanh toán
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentConfirmationDetailScreen(
                      idBank: widget.idBank,
                      balance: widget.balance,
                      idTransaction: _jobTransaction.idTransaction,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Thanh toán ngay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(_package.price)} đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Định dạng tiền tệ
  String _formatCurrency(double amount) {
    String fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    String integerPart = parts[0];
    String decimalPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }
    String formatted = buffer.toString(); 
    if (decimalPart != '00') {
      formatted = '$formatted,$decimalPart';
    }
    return formatted;
  }

}