import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import package intl cho định dạng tiền tệ

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
      isSelected: true, // Mặc định chọn thẻ tín dụng
    ),
    PaymentMethod(
      id: 'momo',
      name: 'Ví MoMo',
      icon: Icons.account_balance_wallet,
      isSelected: false,
    ),
    PaymentMethod(
      id: 'banking',
      name: 'Chuyển khoản ngân hàng',
      icon: Icons.account_balance,
      isSelected: false,
    ),
  ];

  final List<ServiceItem> _selectedServices = [
    ServiceItem(
      name: 'Gói Kết nối Chuyên nghiệp',
      price: 1200000,
      duration: '30 ngày',
      icon: Icons.star_border, // Thêm icon cho service
    ),
    ServiceItem(
      name: 'Hỗ trợ Ưu tiên 24/7',
      price: 800000,
      duration: '15 ngày',
      icon: Icons.headset_mic, // Thêm icon cho service
    ),
  ];

  int get _totalAmount =>
      _selectedServices.fold(0, (sum, item) => sum + item.price);

  // Controllers cho thông tin khách hàng
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method.isSelected = method.id == id;
      }
    });
  }

  void _processPayment() {
    // Basic validation
    if (_fullNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin khách hàng.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method.isSelected,
    );

    // Show loading indicator or dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Đang xử lý thanh toán bằng ${selectedMethod.name}...'),
              ],
            ),
          ),
    );

    // Simulate payment processing time
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Check payment status (simulated)
      bool paymentSuccess =
          true; // In real app, this would come from API response

      if (paymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanh toán ${_formatCurrency(_totalAmount)} đ thành công!',
            ),
            backgroundColor:
                Colors.green.shade600, // Sử dụng màu xanh lá cây mạnh hơn
          ),
        );
        // Navigate to success screen or update UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thất bại. Vui lòng thử lại.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Sử dụng màu nền từ theme
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Thanh toán",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface, // Màu chữ từ theme
          ),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Màu AppBar từ theme
        foregroundColor:
            theme
                .appBarTheme
                .foregroundColor, // Màu icon/text mặc định của AppBar
        centerTitle: true,
      ),
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
                      _buildServicesSummary(
                        theme,
                        isDarkMode,
                      ), // Truyền theme và isDarkMode
                      const SizedBox(height: 24),
                      _buildPaymentMethodsSection(
                        theme,
                        isDarkMode,
                      ), // Truyền theme và isDarkMode
                      const SizedBox(height: 24),
                      _buildBillingDetailsSection(theme), // Truyền theme
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(theme, isDarkMode), // Truyền theme và isDarkMode
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSummary(ThemeData theme, bool isDarkMode) {
    return Card(
      elevation: 4, // Tăng elevation nhẹ cho card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bo tròn hơn
      ),
      color: theme.cardColor, // Sử dụng màu card từ theme
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Tăng padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dịch vụ đã chọn',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20), // Tăng khoảng cách
            ...List.generate(_selectedServices.length, (index) {
              final service = _selectedServices[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _selectedServices.length - 1 ? 0 : 16.0,
                ), // Padding cuối cùng
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                  children: [
                    Container(
                      width: 48, // Kích thước icon lớn hơn
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha:
                          0.1,
                        ), // Màu primary nhẹ
                        borderRadius: BorderRadius.circular(12), // Bo tròn hơn
                      ),
                      child: Icon(
                        service.icon ??
                            Icons
                                .category, // Dùng icon của service, nếu không có thì dùng category
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.duration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor, // Màu xám nhạt hơn
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatCurrency(
                        service.price,
                      ), // Không thêm ' đ' ở đây, thêm ở hàm format
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface, // Màu chữ tổng quát
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20), // Khoảng cách trước divider
            Divider(
              color: theme.dividerColor,
              thickness: 1.5,
            ), // Divider từ theme, dày hơn
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formatCurrency(_totalAmount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    // Kích thước lớn hơn
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary, // Màu primary
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection(ThemeData theme, bool isDarkMode) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phương thức thanh toán',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _paymentMethods.length - 1 ? 0 : 16.0,
                ),
                child: InkWell(
                  onTap: () => _selectPaymentMethod(method.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            method.isSelected
                                ? theme
                                    .colorScheme
                                    .primary // Màu primary khi chọn
                                : theme
                                    .dividerColor, // Màu divider khi không chọn
                        width: method.isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color:
                          method.isSelected
                              ? theme.colorScheme.primary.withValues(alpha:
                                isDarkMode ? 0.1 : 0.05,
                              ) // Màu nền nhẹ khi chọn
                              : theme.cardColor, // Màu nền card khi không chọn
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            method.icon,
                            color:
                                method.isSelected
                                    ? theme.colorScheme.primary
                                    : theme.iconTheme.color,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              method.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight:
                                    method.isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (method.isSelected)
                            Icon(
                              Icons.check_circle_rounded, // Icon check đẹp hơn
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                        ],
                      ),
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

  Widget _buildBillingDetailsSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin khách hàng',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              theme: theme,
              label: 'Họ và tên',
              hint: 'Nguyễn Văn A',
              prefixIcon: Icons.person_outline,
              controller: _fullNameController,
            ),
            _buildTextField(
              theme: theme,
              label: 'Số điện thoại',
              hint: '09xxxxxxxx',
              prefixIcon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              controller: _phoneController,
            ),
            _buildTextField(
              theme: theme,
              label: 'Email',
              hint: 'example@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600, // Đậm hơn một chút
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10), // Khoảng cách lớn hơn
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor.withValues(alpha:0.7), // Màu hint nhạt hơn
              ),
              prefixIcon: Icon(
                prefixIcon,
                size: 22,
                color: theme.iconTheme.color?.withValues(alpha:0.7),
              ),
              filled: true,
              fillColor:
                  theme.inputDecorationTheme.fillColor ??
                  theme.colorScheme.surface, // Màu nền input từ theme
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Bo tròn hơn
                borderSide: BorderSide(
                  color: theme.dividerColor,
                  width: 1.5,
                ), // Viền từ theme, dày hơn
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ), // Viền primary khi focus
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ), // Thêm horizontal padding
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ), // Tăng padding
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withValues(alpha:0.2)
                    : Colors.black.withValues(alpha:
                      0.08,
                    ), // Điều chỉnh shadow cho dark mode
            blurRadius: 15, // Tăng blur
            offset: const Offset(0, -6), // Đẩy shadow lên cao hơn
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Để nút không bị dính vào notch dưới
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng thanh toán',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.hintColor, // Màu xám nhạt
                    ),
                  ),
                  const SizedBox(height: 6), // Tăng khoảng cách
                  Text(
                    _formatCurrency(_totalAmount),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      // Kích thước lớn hơn
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _processPayment, // Gán hàm xử lý thanh toán
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Màu primary
                foregroundColor:
                    theme.colorScheme.onPrimary, // Màu chữ trên primary
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ), // Tăng padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Bo tròn hơn
                ),
                elevation: 5, // Thêm elevation cho nút
              ),
              child: Text(
                'Thanh toán ngay',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sử dụng NumberFormat từ package intl để định dạng tiền tệ chuẩn hơn
  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ', // Ký hiệu tiền tệ Việt Nam
      decimalDigits: 0, // Không có số thập phân
    );
    return formatter.format(amount);
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false, // Mặc định không chọn
  });
}

class ServiceItem {
  final String name;
  final int price;
  final String duration;
  final IconData? icon; // Thêm icon tùy chọn

  ServiceItem({
    required this.name,
    required this.price,
    required this.duration,
    this.icon,
  });
}
