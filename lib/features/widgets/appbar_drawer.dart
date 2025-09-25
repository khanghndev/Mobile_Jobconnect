import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; 
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_string.dart';
import 'package:job_connect/data/models/account_model.dart';
import 'package:job_connect/data/models/notification_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/help/screens/help_screen.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/job/screens/job_matching_screen.dart';
import 'package:job_connect/features/notifications/screens/notification_screen.dart';
import 'package:job_connect/features/resume/screens/cv_analysis_screen.dart';
import 'package:job_connect/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBarWithDrawer extends StatefulWidget {
  final Widget bodyBuilder;
  final bool isLoggedIn;
  final String idUser;
  final String title;

  const CustomAppBarWithDrawer({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.bodyBuilder,
    this.title = AppStrings.appName,
  });

  @override
  CustomAppBarWithDrawerState createState() => CustomAppBarWithDrawerState();
}

class CustomAppBarWithDrawerState extends State<CustomAppBarWithDrawer> with TickerProviderStateMixin {
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  int unreadNotifications = 0;
  Account? _account;
  bool _isLoading = false;
  RefreshCallback? _childScreenRefreshCallback;

  // Animation cho badge thông báo
  late AnimationController _badgeAnimationController;
  late Animation<double> _badgeScaleAnimation;

  void _registerChildRefreshCallback(RefreshCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _childScreenRefreshCallback = callback);
    });
  }

  @override
  void initState() {
    super.initState();
    _badgeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _badgeScaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(
        parent: _badgeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _initializeData();
  }

  @override
  void dispose() {
    _badgeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadDataForAppBarAndDrawer();
  }

  Future<void> _loadDataForAppBarAndDrawer() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        if (widget.idUser.isNotEmpty) _fetchAccount(),
        if (widget.idUser.isNotEmpty) _fetchUnreadNotificationsCount(),
      ]);
    } catch (e) {
      debugPrint("Error loading app bar/drawer data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadDataForAppBarAndDrawer();
    if (_childScreenRefreshCallback != null) {
      await _childScreenRefreshCallback!();
    }
  }

  Future<void> _fetchAccount() async {
    // ... (logic giữ nguyên)
    if (widget.idUser.isEmpty) {
      if (mounted) setState(() => _account = null);
      return;
    }
    try {
      final dynamic responseData = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (mounted) {
        if (responseData != null &&
            responseData is List &&
            responseData.isNotEmpty) {
          _account = Account.fromJson(
            responseData.first as Map<String, dynamic>,
          );
        } else if (responseData is Map<String, dynamic>) {
          _account = Account.fromJson(responseData);
        } else {
          _account = null;
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error fetching account for appbar: $e');
      if (mounted) setState(() => _account = null);
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    // ... (logic giữ nguyên)
    if (widget.idUser.isEmpty) {
      if (mounted) setState(() => unreadNotifications = 0);
      return;
    }
    try {
      final dynamic responseData = await _apiService.get(
        "${ApiConstants.notificationEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        int previousUnread = unreadNotifications;
        if (responseData != null && responseData is List) {
          List<NotificationModel> notifications =
              responseData
                  .where((item) => item is Map<String, dynamic>)
                  .map(
                    (item) => NotificationModel.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();
          unreadNotifications =
              notifications.where((n) => n.isRead == 0).length;
        } else {
          unreadNotifications = 0;
        }
        // Chạy animation nếu số lượng thay đổi và lớn hơn 0
        if (unreadNotifications > 0 && unreadNotifications != previousUnread) {
          _badgeAnimationController.forward(from: 0.0);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching notifications for appbar: $e");
      if (mounted) setState(() => unreadNotifications = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: isDarkMode ? 0.5 : 1.0, // Shadow nhẹ nhàng hơn
        backgroundColor:
            isDarkMode
                ? theme.colorScheme.surface.withOpacity(0.98)
                : Colors.white,
        toolbarHeight: 70, // Giữ nguyên hoặc điều chỉnh nếu cần
        leadingWidth: 65, // Tăng một chút cho padding
        leading: Builder(
          builder:
              (context) => Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                ), // Giảm padding trái
                child: IconButton(
                  icon: Icon(
                    Icons.menu_open_rounded, // Icon menu khác
                    color: theme.colorScheme.onSurface, // Màu icon theo theme
                    size: 28,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: "Mở menu",
                  splashRadius: 24,
                ),
              ),
        ),
        title: Text(
          widget.title, // Giữ nguyên hoặc đổi font
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary, // Màu primary cho tiêu đề
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3, // Giảm letter spacing
          ),
        ),
        centerTitle: true,
        actions: [
          _buildNotificationIcon(theme),
          const SizedBox(width: 8),
          _buildProfileAvatar(theme),
          const SizedBox(width: 8), // Khoảng cách cuối
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          // Tùy chỉnh status bar
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      drawer: _buildDrawer(context, theme), // Truyền theme vào drawer
      body: widget.bodyBuilder,
    );
  }

  Widget _buildNotificationIcon(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0), // Giảm padding
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded, // Icon outline
              color: theme.colorScheme.onSurfaceVariant,
              size: 28, // Tăng kích thước icon
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NotificationsScreen(idUser: widget.idUser),
                ),
              );
              _fetchUnreadNotificationsCount(); // Luôn fetch lại sau khi quay về
            },
            tooltip: "Thông báo",
            splashRadius: 24,
          ),
          if (widget.isLoggedIn && unreadNotifications > 0)
            Positioned(
              right: 8, // Điều chỉnh vị trí badge
              top: 8,
              child: ScaleTransition(
                // Animation cho badge
                scale: _badgeScaleAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ), // Padding cho badge
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error, // Màu error cho badge
                    borderRadius: BorderRadius.circular(10), // Bo tròn hơn
                    border: Border.all(
                      color: theme.cardColor,
                      width: 1.5,
                    ), // Viền trắng
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // Font nhỏ hơn
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0), // Giảm padding
      child: InkWell(
        // InkWell để có hiệu ứng chạm
        onTap: () async {
          if (widget.isLoggedIn) {
            HomePage.goToProfileTab(context);
          } else {
            _showLoginRequiredDialog();
          }
        },
        borderRadius: BorderRadius.circular(20), // Bo tròn cho hiệu ứng chạm
        child: Container(
          padding: const EdgeInsets.all(3), // Padding tạo border
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                widget.isLoggedIn &&
                        _account?.avatarUrl != null &&
                        _account!.avatarUrl!.isNotEmpty
                    ? LinearGradient(
                      // Gradient border cho avatar có ảnh
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            border:
                widget.isLoggedIn &&
                        (_account?.avatarUrl == null ||
                            _account!.avatarUrl!.isEmpty)
                    ? Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                      width: 1.5,
                    ) // Border cho avatar mặc định
                    : null,
          ),
          child: CircleAvatar(
            radius: 18, // Kích thước avatar
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            backgroundImage:
                (widget.isLoggedIn &&
                        _account?.avatarUrl != null &&
                        _account!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(_account!.avatarUrl!)
                    : null,
            child:
                (widget.isLoggedIn &&
                        _account?.avatarUrl != null &&
                        _account!.avatarUrl!.isNotEmpty)
                    ? null
                    : Icon(
                      widget.isLoggedIn
                          ? Icons.person_rounded
                          : Icons.login_rounded, // Icon khác khi chưa đăng nhập
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    // Nhận theme
    final isDarkMode = theme.brightness == Brightness.dark;
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 8, // Tăng elevation cho drawer
      child: Column(
        // Sử dụng Column để có thể thêm footer nếu muốn
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  // Sử dụng UserAccountsDrawerHeader cho đẹp hơn
                  accountName: Text(
                    widget.isLoggedIn
                        ? (_account?.userName ?? "Người dùng ${AppStrings.appName}")
                        : "Khách Truy Cập",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    widget.isLoggedIn
                        ? (_account?.email ?? "Chào mừng bạn!")
                        : "Vui lòng đăng nhập để trải nghiệm",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    backgroundImage:
                        (widget.isLoggedIn &&
                                _account?.avatarUrl != null &&
                                _account!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(_account!.avatarUrl!)
                            : null,
                    child:
                        (widget.isLoggedIn &&
                                _account?.avatarUrl != null &&
                                _account!.avatarUrl!.isNotEmpty)
                            ? null
                            : Text(
                              widget.isLoggedIn &&
                                      _account?.userName != null &&
                                      _account!.userName!.isNotEmpty
                                  ? _account!.userName![0].toUpperCase()
                                  : "H",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.75),
                        theme.colorScheme.secondary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  margin: EdgeInsets.zero, // Bỏ margin mặc định
                ),
                
                _buildDrawerItem(
                  context,
                  Icons.home_filled,
                  "Trang chủ",
                  theme,
                  isSelected: true,
                  onTap: () {
                    // Đã ở trang chủ, chỉ đóng drawer
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.document_scanner_outlined,
                  "Phân tích CV",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CVAnalysisPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.bookmark_added_outlined,
                  "Công việc đã lưu",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    HomePage.goToSearchTab(context, initialTabIndex: 2);
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.history_edu_outlined,
                  "Lịch sử ứng tuyển",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                JobHistoryScreen(idUser: widget.idUser),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.recommend_outlined,
                  'Gợi ý công việc',
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                JobMatchingScreen(idUser: widget.idUser),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Divider(
                    color: theme.dividerColor.withOpacity(0.5),
                    height: 1,
                  ),
                ),
                _buildSectionTitle(context, "UniJobs"),
                _buildDrawerItem(
                  context,
                  Icons.home_outlined,
                  'Bảng tin',
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    context.push('/job-board');
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.person_outlined,
                  'Trang cá nhân',
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.edit_note_outlined,
                  "Tạo bài viết",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    context.push('/create-post');
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.people_outline,
                  "Kết nối",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    context.push('/connections');
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Divider(
                    color: theme.dividerColor.withOpacity(0.5),
                    height: 1,
                  ),
                ),
                _buildSectionTitle(context, "Hệ thống"),
                _buildDrawerItem(
                  context,
                  Icons.feedback_outlined,
                  "Kiểm tra hành vi",
                  theme,
                  onTap: () {
                    if (!widget.isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }
                    context.push('/check');
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_outlined,
                  "Cài đặt",
                  theme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SettingScreen(
                              isLoggedIn: widget.isLoggedIn,
                              idUser: widget.idUser,
                            ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.support_agent_outlined,
                  "Trợ giúp & Hỗ trợ",
                  theme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Footer của Drawer (ví dụ: nút đăng xuất/đăng nhập)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child:
                widget.isLoggedIn
                    ? _buildDrawerItem(
                      context,
                      Icons.logout_rounded,
                      "Đăng xuất",
                      theme,
                      itemColor: theme.colorScheme.error,
                      onTap: () => _logout(context),
                    )
                    : _buildDrawerItem(
                      context,
                      Icons.login_rounded,
                      "Đăng nhập",
                      theme,
                      itemColor: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    ThemeData theme, {
    bool isSelected = false,
    VoidCallback? onTap,
    Color? itemColor,
  }) {
    final color =
        itemColor ??
        (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant);
    return Material(
      // Thêm Material để có hiệu ứng ripple
      color:
          isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) onTap();
        },
        splashColor: theme.colorScheme.primary.withOpacity(0.12),
        highlightColor: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ), // Tăng padding
          child: Row(
            children: [
              Icon(icon, color: color, size: 24), // Icon lớn hơn một chút
              const SizedBox(width: 20), // Tăng khoảng cách
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  // Sử dụng titleSmall
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Các hàm _logout, _buildLogoutDialog, _showLoginRequiredDialog giữ nguyên logic, đảm bảo sử dụng theme)
  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ), // Bo góc lớn hơn
            elevation: 5,
            backgroundColor: Colors.transparent, // Để Container con kiểm soát
            child: _buildLogoutDialog(context),
          ),
    );
    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('userId', "");
      if (mounted) {
        // Kiểm tra mounted trước khi dùng context
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

  Widget _buildLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(0), // Bỏ padding ở đây
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ), // Tăng padding
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
                  padding: const EdgeInsets.all(14), // Tăng padding icon
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
                  ), // Icon khác
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
                  'Bạn có chắc chắn muốn kết thúc phiên làm việc hiện tại?', // Thay đổi text
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ), // Tăng padding
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
                          backgroundColor:
                              theme
                                  .colorScheme
                                  .error, // Màu error cho nút đăng xuất
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

  void _showLoginRequiredDialog() {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.6), // Tăng độ mờ
      transitionDuration: const Duration(milliseconds: 350), // Tăng thời gian
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ); // Curve khác
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
              ), // Bo góc lớn hơn
              elevation: 8, // Tăng elevation
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
                            ), // Icon khác
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
                            'Để tiếp tục, bạn cần đăng nhập vào tài khoản ${AppStrings.appName}. Khám phá ngay!', // Text mới
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
                              // Thêm icon
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
                                ), // Tăng padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ), // Bo góc
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
