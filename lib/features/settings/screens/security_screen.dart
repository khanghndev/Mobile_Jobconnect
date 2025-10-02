// lib/features/settings/screens/security_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Thêm import này
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ThemeProvider

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  // bool _biometricEnabled = false; // Bỏ biến này, sẽ lấy từ ThemeProvider

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  // Hàm tải cài đặt bảo mật từ SharedPreferences
  Future<void> _loadSecuritySettings() async {
    // Không cần load _biometricEnabled ở đây nữa vì ThemeProvider đã làm
    // và chúng ta sẽ lắng nghe ThemeProvider.
    // LƯU Ý: nếu 2FA cũng muốn quản lý bằng provider thì cũng cần thêm provider cho nó.
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
      });
    }
  }

  // Hàm lưu cài đặt bảo mật vào SharedPreferences
  Future<void> _saveSecuritySetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Lắng nghe ThemeProvider

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bảo mật",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSettingSection([
              _buildSettingItem(
                icon: Icons.lock_reset_outlined,
                title: "Đổi mật khẩu",
                subtitle: "Đặt lại mật khẩu tài khoản của bạn",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tính năng đổi mật khẩu đang được phát triển.',
                      ),
                    ),
                  );
                },
              ),
            ]),

            _buildSectionHeader(context, "Bảo mật nâng cao"),
            _buildSettingSection([
              _buildSwitchSettingItem(
                icon: Icons.verified_user_outlined,
                title: "Xác thực hai yếu tố",
                subtitle:
                    "Yêu cầu mã xác minh khi đăng nhập trên thiết bị mới.",
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                  _saveSecuritySetting('two_factor_enabled', value);
                },
              ),
              _buildSwitchSettingItem(
                icon: Icons.fingerprint,
                title: "Đăng nhập sinh trắc học",
                subtitle:
                    "Sử dụng vân tay hoặc Face ID để đăng nhập nhanh chóng.",
                value:
                    themeProvider
                        .biometricEnabled, // Lấy giá trị từ ThemeProvider
                onChanged: (value) {
                  // Gọi phương thức từ ThemeProvider để cập nhật
                  themeProvider.toggleBiometric(value);
                  // Có thể thêm logic kiểm tra sinh trắc học thực tế ở đây
                  // hoặc giữ lại hàm _toggleBiometricAuth trong SettingScreen
                  // và điều hướng về SettingScreen sau khi bật/tắt để xử lý.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đăng nhập sinh trắc học đã ${value ? 'bật' : 'tắt'} trên SettingScreen.',
                      ),
                    ),
                  );
                },
              ),
            ]),

            _buildSectionHeader(context, "Hoạt động tài khoản"),
            _buildSettingSection([
              _buildSettingItem(
                icon: Icons.history,
                title: "Hoạt động đăng nhập",
                subtitle: "Xem các phiên đăng nhập gần đây của bạn.",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Xem lịch sử đăng nhập đang được phát triển.',
                      ),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.devices_other_outlined,
                title: "Thiết bị đã đăng nhập",
                subtitle:
                    "Xem và quản lý các thiết bị đã đăng nhập tài khoản của bạn.",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quản lý thiết bị đang được phát triển.'),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
