// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:job_connect/model/subscription_package_model.dart';

import '../../../services/subscriptionpackage_service.dart';
import 'hr_payment_screen.dart';

class HrSubscriptionScreen extends StatefulWidget {
  String idBank;
  double balance;
  final String recruiterId;
  final String currentPackageId;
  HrSubscriptionScreen({
    super.key,
    required this.idBank,
    required this.balance,
    required this.recruiterId,
    required this.currentPackageId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HrSubscriptionScreenState createState() => _HrSubscriptionScreenState();
}

class _HrSubscriptionScreenState extends State<HrSubscriptionScreen> {
  final SubscriptionPackageService _service = SubscriptionPackageService();

  List<SubscriptionPackageModel> _packages = [];
  String _selectedId = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  // Lấy danh sách gói dịch vụ từ API
  Future<void> _fetchPackages() async {
    try {
      final packages = await _service.fetchSubscriptionPackages();
      if (!mounted) return;
     setState(() {
      _packages = packages;
      _selectedId = ''; // Không chọn trước gói nào
      _isLoading = false;
    });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lấy gói dịch vụ: $e'), backgroundColor: Colors.red,),
      );
    }
  }

  // Lấy gói dịch vụ đã chọn
  // Nếu không tìm thấy gói dịch vụ nào thì lấy gói đầu tiên
  // Nếu không có gói dịch vụ nào thì trả về null
  SubscriptionPackageModel get _selectedPackage {
    return _packages.firstWhere(
      (p) => p.idPackage == _selectedId,
      orElse: () => _packages.first,
    );
  }

  // Hàm này được gọi khi người dùng chọn một gói dịch vụ
  void _onSelect(String id) {
    setState(() => _selectedId = id);
  }

  @override
  Widget build(BuildContext context) {
    // final hasAffordablePackage = _packages.any((pkg) => pkg.price <= widget.balance);
    final hasAffordablePackage = _packages
    .where((pkg) => pkg.price > 0)
    .any((pkg) => pkg.price <= widget.balance);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chọn gói dịch vụ")),
        body: Center(child: Text("Lỗi: $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn gói dịch vụ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final pkg = _packages[i];
                final sel = pkg.idPackage == _selectedId;
                final canAfford = pkg.price <= widget.balance;

                return Opacity(
                  opacity: canAfford ? 1.0 : 0.4, // Làm mờ nếu không đủ tiền
                  child: AbsorbPointer(
                    absorbing: !canAfford, // Không cho tương tác nếu không đủ tiền
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: sel ? Colors.blue : Colors.grey.shade300,
                          width: sel ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ExpansionTile(
                        key: Key(pkg.idPackage),
                        initiallyExpanded: sel,
                        onExpansionChanged: (open) {
                          if (open) _onSelect(pkg.idPackage);
                        },
                        leading: Icon(
                          sel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: sel ? Colors.blue : Colors.grey,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pkg.packageName,
                                style: TextStyle(
                                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${_formatCurrency(pkg.price)} đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: sel ? Colors.blue : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('${pkg.durationDays} ngày'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (pkg.description != null && pkg.description!.isNotEmpty) ...[
                                  Text(
                                    pkg.description!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Text('Giới hạn tin đăng: ${pkg.jobPostLimit}'),
                                Text('Giới hạn xem CV: ${pkg.cvViewLimit}'),
                                if (!canAfford)
                                  const Text(
                                    '⚠️ Không đủ số dư để mua gói này',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              },
            ),
          ),

          // Nút thanh toán
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: hasAffordablePackage
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HrPaymentScreen(
                              idBank: widget.idBank,
                              balance: widget.balance,
                              package: _selectedPackage,
                              recruiterId: widget.recruiterId,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasAffordablePackage ? Colors.blue : Colors.grey.shade400,
                ),
                child: const Text('Thanh toán'),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Định dạng số tiền thành chuỗi với dấu phân cách hàng nghìn
  // Ví dụ: 1000000 -> "1.000.000"
  String _formatCurrency(double val) {
    final s = val.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
