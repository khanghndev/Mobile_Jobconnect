import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/account_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/help/screens/help_screen.dart';
import 'package:job_connect/features/payments/screens/payment_screen.dart';
import 'package:job_connect/features/profile/screens/edit_profile_screen.dart';
import 'package:job_connect/features/settings/screens/about_screen.dart';
import 'package:job_connect/features/settings/screens/privacy_screen.dart';
import 'package:job_connect/features/settings/screens/security_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:job_connect/core/config/providers/theme_provider.dart';
import 'package:job_connect/core/config/providers/text_size_provider.dart';

class SettingScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const SettingScreen({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
  });

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin {
  // Thêm TickerProviderStateMixin
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  final LocalAuthentication auth = LocalAuthentication();
  bool _isLoading = true;
  Account? _account;

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';

  late AnimationController
  _staggerAnimationController; // Animation cho các section

  @override
  void initState() {
    super.initState();
    _staggerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ), // Thời gian animation dài hơn
    );
    _initializeData();
  }

  @override
  void dispose() {
    _staggerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadSettings();
    await _loadAllData();
    if (mounted) {
      _staggerAnimationController.forward(); // Chạy animation sau khi tải xong
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedLanguage =
            prefs.getString('selected_language') ?? 'Tiếng Việt';
      });
    }
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)
      await prefs.setBool(key, value);
    else if (value is double)
      await prefs.setDouble(key, value);
    else if (value is String)
      await prefs.setString(key, value);
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    await Future.wait([_fetchAccount()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchAccount() async {
    if (widget.idUser.isEmpty) {
      // Sửa: idUser không thể null
      if (mounted) setState(() => _account = null);
      return;
    }
    try {
      final response = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (response != null && response.isNotEmpty) {
        if (mounted)
          setState(() => _account = Account.fromJson(response.first));
      } else {
        if (mounted) setState(() => _account = null);
      }
    } catch (e) {
      if (mounted) setState(() => _account = null);
    }
  }

  Future<void> _onRefresh() async {
    _staggerAnimationController.reset();
    await _loadAllData();
    if (mounted) _staggerAnimationController.forward();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã làm mới cài đặt')));
  }

  Future<void> _logout() async {
    // ... (Giữ nguyên logic logout, đảm bảo sử dụng _buildLogoutDialog đã được theme)
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            backgroundColor: Colors.transparent,
            child: _buildLogoutDialog(
              context,
              Theme.of(context),
            ), // Truyền theme
          ),
    );
    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('userId', "");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng xuất thành công")));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _toggleBiometricAuth(
    bool enable,
    ThemeProvider themeProvider,
  ) async {
    // Nhận themeProvider
    if (enable) {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thiết bị này không hỗ trợ sinh trắc học.'),
            ),
          );
        return;
      }
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Vui lòng cài đặt ít nhất một phương thức sinh trắc học.',
              ),
            ),
          );
        return;
      }
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Vui lòng xác thực để bật đăng nhập sinh trắc học',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ), // Yêu cầu chỉ sinh trắc học
        );
        if (authenticated) {
          if (mounted) {
            themeProvider.toggleBiometric(true); // Cập nhật provider
            _saveSetting('biometric_enabled', true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đăng nhập sinh trắc học đã được bật.'),
              ),
            );
          }
        } else {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xác thực không thành công.')),
            );
        }
      } on PlatformException catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi sinh trắc học: ${e.message}')),
          );
      }
    } else {
      themeProvider.toggleBiometric(false);
      _saveSetting('biometric_enabled', false);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập sinh trắc học đã được tắt.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textSizeProvider = Provider.of<TextSizeProvider>(context);
    final theme = Theme.of(context); // Lấy theme hiện tại
    final isDarkMode = theme.brightness == Brightness.dark;

    final systemOverlayStyle =
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    if (_isLoading && _account == null) {
      // Chỉ loading toàn màn hình khi chưa có dữ liệu ban đầu
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.appBarTheme.iconTheme?.color,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Text(
            "Cài Đặt & Tùy Chỉnh",
            style: theme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          systemOverlayStyle: systemOverlayStyle,
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }
    // Không cần kiểm tra _account == null nữa vì đã có CustomAppBarWithDrawer xử lý

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          "Cài Đặt & Tùy Chỉnh",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDarkMode
                ? theme.colorScheme.surface.withOpacity(0.95)
                : Colors.white,
        elevation: 0.8,
        systemOverlayStyle: systemOverlayStyle,
      ),
      body: RefreshIndicator(
        // Thêm RefreshIndicator
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ), // Luôn cho phép cuộn
          child: Padding(
            // Thêm Padding tổng thể
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                // Animation cho các section
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  if (widget.isLoggedIn && _account != null)
                    _buildProfileHeader(theme),
                  if (!widget.isLoggedIn) _buildLoginPrompt(theme),

                  _buildSectionHeader(
                    theme,
                    "Tài Khoản",
                    Icons.account_circle_outlined,
                  ),
                  _buildSettingSection(theme, [
                    _buildSettingItem(
                      theme,
                      Icons.manage_accounts_outlined,
                      "Thông tin cá nhân",
                      subtitle: "Chỉnh sửa hồ sơ, ảnh đại diện",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          _showLoginRequiredDialog(theme);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditProfilePage(idUser: widget.idUser),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                    _buildSettingItem(
                      theme,
                      Icons.shield_outlined,
                      "Bảo mật & Quyền riêng tư",
                      subtitle: "Mật khẩu, xác thực, dữ liệu",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          _showLoginRequiredDialog(theme);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecurityScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                    _buildSettingItem(
                      theme,
                      Icons.credit_card_outlined,
                      "Thanh toán & Gói dịch vụ",
                      subtitle: "Quản lý gói Premium, lịch sử",
                      onTap: () {
                        if (!widget.isLoggedIn) {
                          _showLoginRequiredDialog(theme);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentPage(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                  ]),

                  _buildSectionHeader(
                    theme,
                    "Giao Diện & Hiển Thị",
                    Icons.palette_outlined,
                  ),
                  _buildSettingSection(theme, [
                    _buildSwitchSettingItem(
                      theme,
                      Icons.brightness_6_outlined,
                      "Chế độ tối (Dark Mode)",
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                    ),
                    _buildSliderSettingItem(
                      theme,
                      Icons.format_size_rounded,
                      "Kích thước chữ",
                      value: textSizeProvider.textScaleFactor,
                      min: 0.8,
                      max: 1.5, // Tăng max
                      onChanged: (value) => textSizeProvider.setTextSize(value),
                    ),
                    _buildDropdownSettingItem(
                      theme,
                      Icons.translate_rounded,
                      "Ngôn ngữ hiển thị",
                      value: _selectedLanguage,
                      items: const ['Tiếng Việt', 'English'],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                          _saveSetting('selected_language', value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ngôn ngữ đã đổi thành $value'),
                            ),
                          );
                          // TODO: Implement actual language change logic using a LocaleProvider
                        }
                      },
                    ),
                  ]),

                  _buildSectionHeader(
                    theme,
                    "Thông Báo & Tiện Ích",
                    Icons.notifications_active_outlined,
                  ),
                  _buildSettingSection(theme, [
                    _buildSwitchSettingItem(
                      theme,
                      Icons.notifications_on_outlined,
                      "Bật thông báo đẩy",
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSetting('notifications_enabled', value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thông báo đã ${value ? 'bật' : 'tắt'}',
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.isLoggedIn) // Chỉ hiển thị nếu đã đăng nhập
                      _buildSwitchSettingItem(
                        theme,
                        Icons.fingerprint_rounded,
                        "Đăng nhập sinh trắc học",
                        value: themeProvider.biometricEnabled,
                        onChanged:
                            (value) =>
                                _toggleBiometricAuth(value, themeProvider),
                      ),
                  ]),

                  _buildSectionHeader(
                    theme,
                    "Hỗ Trợ & Khác",
                    Icons.support_agent_rounded,
                  ),
                  _buildSettingSection(theme, [
                    _buildSettingItem(
                      theme,
                      Icons.help_center_outlined,
                      "Trung tâm trợ giúp",
                      subtitle: "Câu hỏi thường gặp, hướng dẫn",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                    _buildSettingItem(
                      theme,
                      Icons.policy_outlined,
                      "Chính sách & Điều khoản",
                      subtitle: "Quyền riêng tư, điều khoản dịch vụ",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                    _buildSettingItem(
                      theme,
                      Icons.info_outline_rounded,
                      "Về HUITERN",
                      subtitle: "Phiên bản ứng dụng, giới thiệu",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  if (widget.isLoggedIn) _buildLogoutButton(theme),
                  if (!widget.isLoggedIn)
                    _buildLoginButton(theme), // Nút đăng nhập nếu chưa login

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "HUITERN App v1.0.0", // Ví dụ
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36, // Tăng kích thước avatar
            backgroundColor: Colors.white.withOpacity(0.9),
            backgroundImage:
                (_account?.avatarUrl != null && _account!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(_account!.avatarUrl!)
                    : null,
            child:
                (_account?.avatarUrl == null || _account!.avatarUrl!.isEmpty)
                    ? Text(
                      _account?.userName?.isNotEmpty == true
                          ? _account!.userName![0].toUpperCase()
                          : "H",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _account?.userName ?? "Người dùng",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  _account?.email ?? "Chưa có email",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(idUser: widget.idUser),
                ),
              ).then((_) => _onRefresh());
            },
            tooltip: "Chỉnh sửa hồ sơ",
            splashRadius: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.login_rounded,
            size: 48,
            color: theme.primaryColor.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn Chưa Đăng Nhập",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Đăng nhập để quản lý tài khoản và trải nghiệm đầy đủ các tính năng của HUITERN.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text("Đăng Nhập Ngay"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 16,
        top: 24,
        bottom: 10,
      ), // Tăng padding
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              // Sử dụng labelLarge
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.8, // Tăng letter spacing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(ThemeData theme, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Tăng vertical margin
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16), // Giữ nguyên bo góc
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.15 : 0.06,
            ), // Điều chỉnh shadow
            blurRadius: 12, // Tăng blur
            offset: const Offset(0, 4), // Điều chỉnh offset
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          // Thêm Divider giữa các item
          return Column(
            children: [
              children[index],
              if (index < children.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingItem(
    ThemeData theme,
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      // Thêm Material để có hiệu ứng ripple
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ), // Cần khớp với bo góc của _buildSettingSection nếu item là con đầu/cuối
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ), // Tăng padding
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42, // Tăng kích thước icon container
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(
                    0.6,
                  ), // Màu nền khác
                  borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.iconTheme.color?.withOpacity(0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem(
    ThemeData theme,
    IconData icon,
    String title, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Giảm padding vertical một chút
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            // Làm Switch nhỏ hơn một chút
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
              inactiveThumbColor: theme.colorScheme.onSurfaceVariant
                  .withOpacity(0.6),
              inactiveTrackColor: theme.colorScheme.onSurfaceVariant
                  .withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSettingItem(
    ThemeData theme,
    IconData icon,
    String title, {
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "${(value * 100).toStringAsFixed(0)}%", // Hiển thị dạng %
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            // Custom SliderTheme
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: theme.primaryColor.withOpacity(0.3),
              thumbColor: theme.primaryColor,
              overlayColor: theme.primaryColor.withOpacity(0.2),
              valueIndicatorColor: theme.primaryColor.withOpacity(0.8),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              trackHeight: 6.0, // Tăng độ dày track
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10.0,
              ), // Thumb to hơn
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 10).toInt(), // Nhiều divisions hơn
              label: "${(value * 100).toStringAsFixed(0)}%", // Label khi kéo
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 0,
            ), // Điều chỉnh padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nhỏ",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                Text(
                  "Vừa",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                Text(
                  "Lớn",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSettingItem(
    ThemeData theme,
    IconData icon,
    String title, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ), // Giảm padding vertical
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            // Bỏ gạch chân mặc định
            child: DropdownButton<String>(
              value: value,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: theme.primaryColor,
                size: 28,
              ), // Icon dropdown
              dropdownColor: theme.cardColor, // Màu nền dropdown
              borderRadius: BorderRadius.circular(10), // Bo góc dropdown
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => _logout(), // Gọi hàm _logout đã được theme
        icon: Icon(
          Icons.power_settings_new_rounded,
          color: theme.colorScheme.onError,
        ),
        label: Text(
          "Đăng Xuất Khỏi Tài Khoản",
          style: TextStyle(
            color: theme.colorScheme.onError,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.8),
          foregroundColor: theme.colorScheme.onErrorContainer,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: theme.colorScheme.error.withOpacity(0.5),
          ), // Viền nhẹ
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.login_rounded, color: Colors.white),
        label: const Text(
          "Đăng Nhập Để Tiếp Tục",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // Giữ nguyên _buildLogoutDialog và _showLoginRequiredDialog, đảm bảo chúng sử dụng theme
  Widget _buildLogoutDialog(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: theme.colorScheme.primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Xác Nhận Đăng Xuất',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Bạn có chắc chắn muốn kết thúc phiên làm việc hiện tại?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: theme.dividerColor.withOpacity(0.7),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Ở LẠI',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'ĐĂNG XUẤT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(ThemeData theme) {
    // Nhận theme
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: theme.cardColor,
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_person_outlined,
                              color: theme.colorScheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Yêu Cầu Đăng Nhập',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          Text(
                            'Để tiếp tục, bạn cần đăng nhập vào tài khoản HUITERN. Khám phá ngay!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, true);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: Text(
                                'ĐĂNG NHẬP NGAY',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'ĐỂ SAU',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
