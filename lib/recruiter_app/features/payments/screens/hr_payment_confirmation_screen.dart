// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/enum/job_transaction_status.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/screen/navigation_recruiter_screen.dart';
import '../../../../features/job/model/job_transaction_detail_model.dart';
import '../../../../features/job/service/job_transaction_detail_service.dart';
import '../../../../features/job/service/job_transaction_service.dart';
import '../../../services/subscriptionpackage_service.dart';

// ignore: must_be_immutable
class PaymentConfirmationDetailScreen extends StatefulWidget {
  String idBank;
  double balance;
  String idTransaction;

  PaymentConfirmationDetailScreen({
    super.key,
    required this.idBank,
    required this.balance,
    required this.idTransaction,
  });

  @override
  State<PaymentConfirmationDetailScreen> createState() => _PaymentConfirmationDetailScreenState();
}

class _PaymentConfirmationDetailScreenState extends State<PaymentConfirmationDetailScreen> {
  // Khởi tạo service
  final JobTransactionService _transactionService = JobTransactionService();
  final JobTransactionDetailService _transactionDetailService = JobTransactionDetailService();
  final UserService _accountService = UserService();
  final SubscriptionPackageService _service = SubscriptionPackageService();

  // Khai báo biến để lưu thông tin giao dịch
  late UserModel account;
  late JobTransactionModel transaction;
  late SubscriptionPackageModel subscriptionPackage;

  // Khai báo biến để lưu thông tin chi tiết giao dịch
  bool _isLoading = true;
  String bank = "Ngân hàng Quân đội";
  String receiverName = "Công ty HuitWork KMTT";
  late String content;
  String? _error;

  // load dữ liệu
  Future<void> loadData() async {
    try {
      // 1. Lấy thông tin giao dịch từ API
      final txn = await _transactionService.getTransactionById(transactionId: widget.idTransaction);
      final acc = await _accountService.getUserById(id: txn!.idUser);
      final pkg = await _service.fetchSubscriptionPackageById(packageId: txn.idPackage);
      if (!mounted) return;
      setState(() {
        transaction = txn;
        account = acc;
        subscriptionPackage = pkg;
        content = "Thanh toán phí dịch vụ ${subscriptionPackage.packageName}";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  void _confirmTransaction() async {
    // 1. Bật trạng thái loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Chuẩn bị đối tượng JobTransactionDetail
      final jobTransactionDetail = JobTransactionDetailModel(
        idTransaction: widget.idTransaction,
        amountFormatted: convertNumberToString(transaction.amount),
        amountInWords: convertNumberToWords(transaction.amount),
        senderName: account.userName,
        senderBank: bank,
        receiverName: receiverName,
        receiverBank: bank,
        content: content,
        fee: "Miễn phí",
      );

      // 3. Gọi API tạo mới chi tiết giao dịch
      await _transactionDetailService.createJobTransactionDetail(detail: jobTransactionDetail);

      // 4. Cập nhật trạng thái giao dịch thành 'accepted'
      await _transactionService.updateTransactionStatus(
        transactionId:  widget.idTransaction,
        newStatus:  JobTransactionStatus.completed.name,
      );

      // Delay 5s
      await Future.delayed(const Duration(seconds: 5));
      
      // 6. Hiển thị thông báo thành công
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác nhận giao dịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Delay thêm 3 giây để người dùng kịp đọc thông báo
      await Future.delayed(const Duration(seconds: 3));

      // 7. Chuyển sang màn hình RecruiterScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationRecruiterScreen(
            isLoggedIn: true,
            userAccount: account,
            currentIndex: 2,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xác nhận giao dịch: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Hàm xóa giao dịch
  Future<void> _deleteTransaction() async {
    try {
      await _transactionService.deleteTransaction(transactionId: widget.idTransaction);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa giao dịch: $e')),
      );
    }
  }

  // Hàm chuyển đổi số thành chữ
  String convertNumberToWords(double number) {
    int num = number.toInt();
    if (num == 0) return "Không";

    final units = [
      "", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"
    ];
    final levels = ["", "nghìn", "triệu", "tỷ"];

    String readThreeDigits(int number) {
      int hundred = number ~/ 100;
      int ten = (number % 100) ~/ 10;
      int unit = number % 10;
      String result = "";

      if (hundred > 0) {
        result += "${units[hundred]} trăm";
        if (ten == 0 && unit > 0) result += " lẻ";
      }

      if (ten > 1) {
        result += " ${units[ten]} mươi";
        if (unit == 1) {
          result += " mốt";
        } else if (unit == 5) {
          result += " lăm";
        } else if (unit > 0) {
          result += " ${units[unit]}";
        }
      } else if (ten == 1) {
        result += " mười";
        if (unit == 5) {
          result += " lăm";
        } else if (unit > 0) {
          result += " ${units[unit]}";
        }
      } else if (unit > 0 && ten == 0) {
        result += " ${units[unit]}";
      }

      return result.trim();
    }

    List<String> parts = [];
    int level = 0;

    while (num > 0) {
      int threeDigits = num % 1000;
      if (threeDigits > 0) {
        String part = readThreeDigits(threeDigits);
        if (levels[level].isNotEmpty) {
          part += " ${levels[level]}";
        }
        parts.insert(0, part);
      }
      num ~/= 1000;
      level++;
    }

    return "${parts.join(" ").replaceAll(RegExp(r'\s+'), ' ').trimLeft().replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase())} nghìn đồng";
  }

  // Hàm hiển thị số có định dạng tiền tệ
  String convertNumberToString(double number) {
    final formatter = NumberFormat("#,###", "vi_VN");
    String formatted = formatter.format(number);
    return "$formatted VND";
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang thanh toán...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2) Nếu có lỗi, hiển thị màn hình lỗi (cũng cần Scaffold)
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Xác nhận thông tin'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 0,
        ),
        body: Center(child: Text("Lỗi: $_error")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận thông tin'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1) Nguồn chuyển tiền
          _buildSourceSection(),

          // 2) Phần nội dung chi tiết (cuộn được khi quá cao)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Card "Số tiền giao dịch" và chi tiết
                  transactionDetailCard(transaction),

                  const SizedBox(height: 16),

                  // Thông báo cảnh báo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      border: Border.all(color: Colors.yellow.shade700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.yellow.shade700),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Vui lòng kiểm tra chính xác thông tin trước khi xác nhận giao dịch.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3) Nút "Quay lại" và "Xác nhận" cố định ở đáy
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => _deleteTransaction(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Quay lại',
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _confirmTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Xác nhận',
                          style: TextStyle(fontSize: 16)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card hiển thị chi tiết giao dịch (số tiền, người chuyển/nhận, ...)
  Widget transactionDetailCard(JobTransactionModel transaction) {
    return Card(
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Số tiền giao dịch',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                convertNumberToString(transaction.amount),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 2),
              Text(convertNumberToWords(transaction.amount),
                  style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 16),
              const Divider(),

              const SizedBox(height: 16),
              const Text('Người chuyển', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              userRow(
                avatar: Icons.person,
                name: account.userName,
                account: '22222',
                bank: bank,
              ),

              const SizedBox(height: 16),
              const Text('Người nhận', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              userRow(
                avatar: Icons.account_balance,
                name: receiverName,
                account: '',
                bank: bank,
              ),

              const SizedBox(height: 16),
              const Divider(),

              const SizedBox(height: 16),
              labelValueRow(
                  label: 'Nội dung chuyển tiền', value: content),

              const SizedBox(height: 8),
              labelValueRow(label: 'Phí giao dịch', value: "Miễn phí"),
              const SizedBox(height: 8),
              labelValueRow(
                  label: 'Hình thức chuyển tiền',
                  value: transaction.paymentMethod!),
            ],
          ),
        ),
      ),
    );
  }

  /// Dòng hiển thị thông tin người dùng: avatar, tên, số tài khoản, ngân hàng
  Widget userRow({
    required IconData avatar,
    required String name,
    required String account,
    required String bank,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: Icon(avatar, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (account.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(account, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 2),
              Text(bank,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  /// Dòng hiển thị label - value
  Widget labelValueRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13))),
        const SizedBox(width: 8),
        Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13))),
      ],
    );
  }

  /// Phần "Nguồn chuyển tiền"
  Widget _buildSourceSection() {
    final double currentBalance = widget.balance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nguồn chuyển tiền',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÀI KHOẢN THANH TOÁN - 00000'
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          convertNumberToString(currentBalance.toDouble()),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 24,
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
