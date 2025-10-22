import 'package:flutter/material.dart';

void main() {
  runApp(const ReferralApp());
}

class ReferralApp extends StatelessWidget {
  const ReferralApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đề xuất ứng viên & Nhận thưởng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2980b9),
          secondary: const Color(0xFF3498db),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
          ),
          bodyLarge: TextStyle(color: Color(0xFF34495e)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 25.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFF3498db), width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 15.0,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2980b9),
          secondary: const Color(0xFF3498db),
          brightness: Brightness.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 25.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const ReferralHomePage(),
    );
  }
}

class ReferralHomePage extends StatefulWidget {
  const ReferralHomePage({Key? key}) : super(key: key);

  @override
  State<ReferralHomePage> createState() => _ReferralHomePageState();
}

class _ReferralHomePageState extends State<ReferralHomePage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _candidateNameController = TextEditingController();
  final _candidateEmailController = TextEditingController();
  final _candidatePhoneController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _yourRelationController = TextEditingController();
  String _selectedPosition = 'Flutter Developer';

  // List of available positions
  final List<String> _positions = [
    'Flutter Developer',
    'Backend Developer',
    'DevOps Engineer',
    'UI/UX Designer',
    'Project Manager',
    'QA Engineer',
    'Data Scientist',
    'Blockchain Developer',
  ];

  // Navigation index for bottom nav
  int _currentIndex = 0;

  @override
  void dispose() {
    _candidateNameController.dispose();
    _candidateEmailController.dispose();
    _candidatePhoneController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _yourRelationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đề xuất ứng viên',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng thông báo sẽ có trong tương lai'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trang hồ sơ cá nhân sẽ có trong tương lai'),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildReferralForm(),
          _buildRewardsPage(),
          _buildHistoryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Đề xuất',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.token),
            label: 'Phần thưởng',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        ],
        selectedItemColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildReferralForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner/Header
              _buildReferralHeader(),
              const SizedBox(height: 24),

              // Form title
              Text(
                'Thông tin ứng viên',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Candidate information fields
              TextFormField(
                controller: _candidateNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên ứng viên *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên ứng viên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _candidateEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email ứng viên *',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email ứng viên';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _candidatePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại ứng viên *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại ứng viên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Position dropdown
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Vị trí ứng tuyển *',
                  prefixIcon: Icon(Icons.work),
                ),
                items:
                    _positions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPosition = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn vị trí ứng tuyển';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Kỹ năng chính',
                  prefixIcon: Icon(Icons.psychology),
                  hintText: 'Ví dụ: Flutter, Firebase, REST API...',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Kinh nghiệm (năm)',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _yourRelationController,
                decoration: const InputDecoration(
                  labelText: 'Mối quan hệ của bạn với ứng viên *',
                  prefixIcon: Icon(Icons.connect_without_contact),
                  hintText: 'Ví dụ: Đồng nghiệp cũ, Bạn học...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mối quan hệ của bạn với ứng viên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Upload CV option
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 8),
                        Text(
                          'Tải lên CV của ứng viên (nếu có)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Chọn tệp'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chức năng tải lên sẽ có trong tương lai',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Terms & Rewards info
              _buildRewardsInfo(),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showSuccessDialog();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text(
                        'Gửi đề xuất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2980b9), Color(0xFF3498db)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha:0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Color(0xFF2980b9),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đề xuất & Nhận thưởng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Giới thiệu ứng viên tài năng và nhận token',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nhận 500 TOKEN cho mỗi ứng viên được tuyển thành công!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Text(
                'Thông tin phần thưởng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Nhận 500 TOKEN khi ứng viên được tuyển dụng\n'
            '• Nhận thêm 100 TOKEN khi ứng viên hoàn thành thử việc\n'
            '• Token có thể đổi thành tiền mặt hoặc voucher\n'
            '• Phần thưởng sẽ được chuyển sau khi xác nhận thông tin',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: true, onChanged: (value) {}),
              const Expanded(
                child: Text(
                  'Tôi xác nhận đã được sự đồng ý của ứng viên và thông tin trên là chính xác',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha:0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ví của tôi',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Icon(Icons.account_balance_wallet, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '1,250 TOKEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tương đương: 1,250,000 VNĐ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Đổi thưởng'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Chức năng đổi thưởng sẽ có trong tương lai',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6a11cb),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text('Lịch sử'),
                          onPressed: () {
                            setState(() {
                              _currentIndex = 2; // Switch to history tab
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6a11cb),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reward Options
            Text(
              'Lựa chọn đổi thưởng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Reward Options Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.85,
              children: [
                _buildRewardCard(
                  icon: Icons.money,
                  title: 'Tiền mặt',
                  description: 'Rút về tài khoản ngân hàng',
                  tokenAmount: '1000 TOKEN',
                ),
                _buildRewardCard(
                  icon: Icons.card_giftcard,
                  title: 'Voucher',
                  description: 'Đổi voucher mua sắm',
                  tokenAmount: '500 TOKEN',
                ),
                _buildRewardCard(
                  icon: Icons.phone_android,
                  title: 'Nạp điện thoại',
                  description: 'Nạp tiền điện thoại',
                  tokenAmount: '200 TOKEN',
                ),
                _buildRewardCard(
                  icon: Icons.shopping_basket,
                  title: 'Quà tặng',
                  description: 'Đổi quà tặng hấp dẫn',
                  tokenAmount: '800 TOKEN',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // How to earn more
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Làm thế nào để kiếm thêm token?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Giới thiệu thêm nhiều ứng viên tiềm năng\n'
                    '• Hoàn thành các nhiệm vụ từ nền tảng\n'
                    '• Tham gia chương trình khảo sát\n'
                    '• Mời thêm người giới thiệu ứng viên',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Thêm ứng viên mới'),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0; // Switch to referral tab
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
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

  Widget _buildRewardCard({
    required IconData icon,
    required String title,
    required String description,
    required String tokenAmount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Bạn đã chọn $title')));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tokenAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch sử hoạt động',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Xem lại tất cả giao dịch và hoạt động của bạn',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Filter by type
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', true),
                  _buildFilterChip('Đề xuất', false),
                  _buildFilterChip('Đổi thưởng', false),
                  _buildFilterChip('Nhận token', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of activities
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'Đề xuất ứng viên thành công',
                  description: 'Nguyễn Văn A - Flutter Developer',
                  timestamp: '02/04/2025',
                  amount: '+500 TOKEN',
                  isPositive: true,
                ),
                _buildActivityItem(
                  icon: Icons.work,
                  title: 'Ứng viên hoàn thành thử việc',
                  description: 'Nguyễn Văn A - Flutter Developer',
                  timestamp: '28/03/2025',
                  amount: '+100 TOKEN',
                  isPositive: true,
                ),
                _buildActivityItem(
                  icon: Icons.money,
                  title: 'Đổi thưởng tiền mặt',
                  description: 'Chuyển khoản đến: **** 5678',
                  timestamp: '15/03/2025',
                  amount: '-1000 TOKEN',
                  isPositive: false,
                ),
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'Đề xuất ứng viên thành công',
                  description: 'Trần Thị B - Backend Developer',
                  timestamp: '05/03/2025',
                  amount: '+500 TOKEN',
                  isPositive: true,
                ),
                _buildActivityItem(
                  icon: Icons.card_giftcard,
                  title: 'Đổi voucher mua sắm',
                  description: 'Voucher Shopee: 500.000 VNĐ',
                  timestamp: '20/02/2025',
                  amount: '-500 TOKEN',
                  isPositive: false,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang tải thêm lịch sử...')),
                  );
                },
                child: const Text('Xem thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Functionality would be implemented here
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã chọn lọc: $label')));
        },
        selectedColor: Theme.of(context).colorScheme.secondary.withValues(alpha:0.2),
        checkmarkColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String timestamp,
    required String amount,
    required bool isPositive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isPositive
                        ? Colors.green.shade50
                        : Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    isPositive
                        ? Colors.green.shade700
                        : Colors.deepOrange.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đề xuất thành công!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cảm ơn bạn đã đề xuất ứng viên ${_candidateNameController.text}. '
                  'Chúng tôi sẽ liên hệ với ứng viên trong thời gian sớm nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Bạn sẽ nhận thông báo về tiến trình',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Reset form
                          _formKey.currentState!.reset();
                          _candidateNameController.clear();
                          _candidateEmailController.clear();
                          _candidatePhoneController.clear();
                          _skillsController.clear();
                          _experienceController.clear();
                          _yourRelationController.clear();
                        },
                        child: const Text('Đóng'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Reset form
                          _formKey.currentState!.reset();
                          _candidateNameController.clear();
                          _candidateEmailController.clear();
                          _candidatePhoneController.clear();
                          _skillsController.clear();
                          _experienceController.clear();
                          _yourRelationController.clear();
                          // Switch to rewards tab
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: const Text('Xem phần thưởng'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Trang chi tiết ứng viên (để triển khai trong tương lai)
class CandidateDetailPage extends StatelessWidget {
  final String candidateName;
  final String position;

  const CandidateDetailPage({
    Key? key,
    required this.candidateName,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết ứng viên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    candidateName.isNotEmpty ? candidateName[0] : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_top,
                                  size: 16,
                                  color: Colors.orange.shade800,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Đang xét duyệt',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status timeline
            const _StatusTimeline(),
            const SizedBox(height: 24),

            // Contact information
            _buildSectionCard(
              title: 'Thông tin liên hệ',
              icon: Icons.contact_mail,
              content: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: 'candidate@example.com',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: 'Điện thoại',
                    value: '0912345678',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Skills information
            _buildSectionCard(
              title: 'Kỹ năng',
              icon: Icons.psychology,
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          'Flutter',
                          'Dart',
                          'Firebase',
                          'REST API',
                          'Git',
                          'UI/UX',
                          'Mobile Development',
                        ]
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(color: Colors.blue.shade800),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Your reward info
            _buildSectionCard(
              title: 'Phần thưởng của bạn',
              icon: Icons.monetization_on,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRewardStatusItem(
                    title: 'Đề xuất ứng viên',
                    status: 'Hoàn thành',
                    reward: '+100 TOKEN',
                    isDone: true,
                  ),
                  _buildRewardStatusItem(
                    title: 'Ứng viên được phỏng vấn',
                    status: 'Đang chờ',
                    reward: '+100 TOKEN',
                    isDone: false,
                  ),
                  _buildRewardStatusItem(
                    title: 'Ứng viên được tuyển dụng',
                    status: 'Đang chờ',
                    reward: '+300 TOKEN',
                    isDone: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cập nhật'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật thông tin mới nhất'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('Liên hệ'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chức năng liên hệ sẽ có trong tương lai',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardStatusItem({
    required String title,
    required String status,
    required String reward,
    required bool isDone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Colors.green : Colors.grey.shade300,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.hourglass_empty,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone ? Colors.green : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            reward,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.green : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {'title': 'Đề xuất', 'date': '02/04/2025', 'isDone': true},
      {'title': 'Đang duyệt', 'date': '03/04/2025', 'isDone': true},
      {'title': 'Phỏng vấn', 'date': 'Đang chờ', 'isDone': false},
      {'title': 'Tuyển dụng', 'date': 'Đang chờ', 'isDone': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trạng thái', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Row(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final bool isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color:
                                step['isDone']
                                    ? Colors.green
                                    : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              step['isDone'] ? Icons.check : null,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                step['isDone']
                                    ? Colors.black
                                    : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['date'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 2,
                        color:
                            steps[index]['isDone'] && steps[index + 1]['isDone']
                                ? Colors.green
                                : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
