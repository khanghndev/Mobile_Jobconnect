import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/notification_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:timeago/timeago.dart' as timeago; //timeago: ^3.2.5

class NotificationsScreen extends StatefulWidget {
  final String? idUser;
  const NotificationsScreen({super.key, this.idUser});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  bool _selectMode = false;
  final Set<String> _selectedNotifications = {};
  List<NotificationModel> _notifications = [];
  bool _isLoading = true; // Added for loading state
  final DateFormat _dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  late AnimationController _listAnimationController; // Animation cho danh sách
  late AnimationController _fabAnimationController; // Animation cho FAB
  late Animation<double> _fabScaleAnimation;
  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _initializeData();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) {
      _listAnimationController.forward();
      if (_notifications.where((n) => n.isRead == 0).isNotEmpty &&
          !_selectMode &&
          !_isLoading) {
        _fabAnimationController.forward();
      }
    }
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    await Future.wait([_loadNotifications()]);
    if (mounted) {
      setState(() => _isLoading = false);
      if (_notifications.where((n) => n.isRead == 0).isNotEmpty &&
          !_selectMode &&
          !_isLoading) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    await _loadAllData();
    if (mounted) _listAnimationController.forward();
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.notificationEndpoint}/${widget.idUser}',
      );
      if (mounted) {
        // setState(() { // Không cần setState ở đây nữa
        _notifications =
            response
                .map<NotificationModel>(
                  (data) => NotificationModel.fromJson(data),
                )
                .toList();
        // Sắp xếp: chưa đọc lên đầu, sau đó theo ngày mới nhất
        _notifications.sort((a, b) {
          if (a.isRead == 0 && b.isRead != 0) return -1;
          if (a.isRead != 0 && b.isRead == 0) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        // });
      }
    } catch (e) {
      print("Error loading notifications: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tải thông báo: ${e.toString()}")),
        );
      }
    }
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedNotifications.clear();
      // Cập nhật trạng thái FAB
      if (_notifications.where((n) => n.isRead == 0).isNotEmpty &&
          !_selectMode &&
          !_isLoading) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedNotifications.contains(id)) {
        _selectedNotifications.remove(id);
      } else {
        _selectedNotifications.add(id);
      }
    });
  }

  Future<void> _markAsRead() async {
    if (_selectedNotifications.isEmpty) return;

    List<Future> updateFutures = [];
    List<NotificationModel> updatedNotifications = List.from(_notifications);

    for (String id in _selectedNotifications) {
      int index = updatedNotifications.indexWhere(
        (n) => n.idNotification == id,
      );
      if (index != -1 && updatedNotifications[index].isRead == 0) {
        NotificationModel updatedNotification = updatedNotifications[index];
        // Optimistically update UI
        updatedNotifications[index] = updatedNotification;
        _apiService.put(
          '${ApiConstants.notificationEndpoint}/${updatedNotification.idNotification}',
          updatedNotification.toJson(),
        );
      }
    }

    setState(() {
      _notifications = updatedNotifications;
      _selectedNotifications.clear();
      _selectMode = false;
    });

    try {
      await Future.wait(updateFutures);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã đánh dấu là đã đọc')));
    } catch (e) {
      // Handle API error, maybe revert UI changes or show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi đánh dấu đã đọc: $e')));
      // Optionally reload notifications to get consistent state
      _loadNotifications();
    }
  }

  Future<void> _deleteNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    List<Future> deleteFutures = [];
    List<String> idsToDelete = List.from(_selectedNotifications);

    // Optimistically update UI
    setState(() {
      _notifications.removeWhere(
        (notification) => idsToDelete.contains(notification.idNotification),
      );
      _selectedNotifications.clear();
      _selectMode = false;
    });

    for (String id in idsToDelete) {
      deleteFutures.add(
        _apiService.delete('${ApiConstants.notificationEndpoint}/$id'),
      );
    }

    try {
      await Future.wait(deleteFutures);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa thông báo')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa thông báo: $e')));
      _loadNotifications();
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    if (_selectMode) {
      _toggleSelect(notification.idNotification);
    } else {
      // Mở thông báo
      // Gọi API để cập nhật trạng thái đã đọc
      if (notification.isRead == 0) {
        int index = _notifications.indexWhere(
          (n) => n.idNotification == notification.idNotification,
        );
        if (index != -1) {
          NotificationModel updatedNotification = _notifications[index];
          updatedNotification.isRead = 1;
          try {
            await _apiService.put(
              '${ApiConstants.notificationEndpoint}/${updatedNotification.idNotification}',
              updatedNotification.toJson(),
            );
          } catch (e) {
            // Handle API error, maybe revert UI or show message
            _notifications[index] = notification; // Revert optimistic update
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
            );
          }
        }
      }
      // Navigate or show details of the notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã mở thông báo: ${notification.title}')),
      );
    }
    _onRefresh();
  }

  Future<void> _markAllAsRead() async {
    if (_notifications.where((n) => n.isRead == 0).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có thông báo nào chưa đọc.')),
      );
      return;
    }

    List<Future> updateFutures = [];
    List<NotificationModel> updatedNotifications = List.from(_notifications);
    bool changed = false;

    for (int i = 0; i < updatedNotifications.length; i++) {
      if (updatedNotifications[i].isRead == 0) {
        changed = true;
        NotificationModel updatedNotification = updatedNotifications[i];
        updatedNotifications[i] = updatedNotification; // Optimistic UI update
        updateFutures.add(
          _apiService.put(
            '${ApiConstants.notificationEndpoint}/${updatedNotification.idNotification}',
            updatedNotification.toJson(),
          ),
        );
      }
    }
    if (!changed) return;

    setState(() {
      _notifications = updatedNotifications;
    });

    try {
      await Future.wait(updateFutures);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đánh dấu tất cả đã đọc: $e')),
      );
      // Optionally reload notifications to get consistent state
      _loadNotifications();
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      // Chuyển sang lowercase để so sánh dễ hơn
      case 'cập nhật ứng tuyển':
        return Icons.rate_review_outlined;
      case 'phỏng vấn':
        return Icons.event_available_outlined;
      case 'việc làm mới':
        return Icons.new_releases_outlined;
      case 'hệ thống':
        return Icons.settings_suggest_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getColorForType(String type, ThemeData theme) {
    // Truyền theme vào
    switch (type.toLowerCase()) {
      case 'cập nhật ứng tuyển':
        return theme.colorScheme.secondary;
      case 'phỏng vấn':
        return Colors.orange.shade700;
      case 'việc làm mới':
        return Colors.green.shade600;
      case 'hệ thống':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  // Bỏ _getColorForStatus vì đã tích hợp vào _buildNotificationItem

  String _getTimeAgo(DateTime dateTime) {
    timeago.setLocaleMessages(
      'vi',
      timeago.ViMessages(),
    ); // Đảm bảo locale tiếng Việt được set
    return timeago.format(dateTime, locale: 'vi');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => n.isRead == 0).length;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF4F6F8), // Nền tinh tế hơn
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.8, // Shadow nhẹ
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Thông Báo', // Tiêu đề mới
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (unreadCount > 0 &&
                !_selectMode) // Chỉ hiển thị khi không ở select mode
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  '$unreadCount tin nhắn mới',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        centerTitle: true,
        leading:
            _selectMode
                ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: _toggleSelectMode,
                  tooltip: "Hủy chọn",
                )
                : IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                ),
        actions: [
          if (_selectMode) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '${_selectedNotifications.length} đã chọn',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.mark_chat_read_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed:
                  _selectedNotifications.isNotEmpty
                      ? _markAsRead
                      : null, // Disable nếu không có item nào được chọn
              tooltip: 'Đánh dấu đã đọc',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: theme.colorScheme.error,
                size: 24,
              ),
              onPressed:
                  _selectedNotifications.isNotEmpty
                      ? _deleteNotifications
                      : null,
              tooltip: 'Xóa thông báo',
            ),
          ] else if (!_isLoading && _notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.checklist_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onPressed: _toggleSelectMode,
              tooltip: 'Quản lý thông báo',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              )
              : _notifications.isEmpty
              ? _buildEmptyNotifications(theme)
              : RefreshIndicator(
                onRefresh: _onRefresh, // Đổi thành _onRefresh
                color: theme.primaryColor,
                backgroundColor: theme.cardColor,
                child: AnimationLimiter(
                  // Thêm AnimationLimiter
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount:
                        _notifications.length, // Không cần +1 cho header nữa
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(height: 0), // Bỏ separator mặc định
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return AnimationConfiguration.staggeredList(
                        // Animation cho từng item
                        position: index,
                        duration: const Duration(milliseconds: 425),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildNotificationItem(notification, theme),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton: ScaleTransition(
        // Animation cho FAB
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: _markAllAsRead,
          icon: const Icon(Icons.done_all_rounded, size: 20),
          label: const Text(
            "Đọc Tất Cả",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Bỏ _buildHeader() vì không cần thiết nữa

  Widget _buildNotificationItem(
    NotificationModel notification,
    ThemeData theme,
  ) {
    final iconData = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type, theme);
    // final statusColor = _getColorForStatus(notification.status); // Sẽ dùng trực tiếp màu từ theme hoặc iconColor
    final timeAgo = _getTimeAgo(notification.createdAt);
    final bool isUnread = notification.isRead == 0;
    final bool isSelected = _selectedNotifications.contains(
      notification.idNotification,
    );

    return Material(
      color:
          _selectMode
              ? (isSelected
                  ? theme.primaryColor.withOpacity(0.15)
                  : theme.cardColor)
              : (isUnread
                  ? theme.primaryColor.withOpacity(0.05)
                  : theme.cardColor),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () {
          if (!_selectMode) {
            _toggleSelectMode();
            _toggleSelect(notification.idNotification);
          }
        },
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.5),
                width: 0.7,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, top: 12),
                  child: IgnorePointer(
                    // Để Checkbox không bắt sự kiện tap riêng
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: null, // Đã xử lý ở onTap của InkWell
                        activeColor: theme.primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: BorderSide(
                          color: theme.primaryColor.withOpacity(0.7),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              Stack(
                // Stack để đặt chấm unread lên icon
                children: [
                  Container(
                    padding: const EdgeInsets.all(12), // Tăng padding icon
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                    ),
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 24,
                    ), // Icon lớn hơn
                  ),
                  if (isUnread &&
                      !_selectMode) // Chỉ hiển thị chấm đỏ khi chưa đọc và không ở select mode
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.error, // Màu đỏ cho chấm unread
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.cardColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                              color:
                                  isUnread
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withOpacity(
                                        0.8,
                                      ),
                              height: 1.3,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2),
                          child: Text(
                            timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      // Hiển thị nội dung thông báo (nếu có) hoặc status
                      notification.status, // Ưu tiên content
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          isUnread ? 0.85 : 0.7,
                        ),
                        height: 1.4,
                      ),
                    ),
                    // const SizedBox(height: 3),
                    // Text(
                    //   _dateFormat.format(notification.dateTime), // Có thể bỏ nếu timeAgo đã đủ
                    //   style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_paused_outlined,
              size: 80,
              color: theme.hintColor.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Hộp Thư Trống',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mọi thông báo quan trọng sẽ xuất hiện ở đây. Hãy kiểm tra thường xuyên nhé!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              // Sử dụng OutlinedButton
              icon: Icon(Icons.refresh_rounded, color: theme.primaryColor),
              label: Text(
                'Làm Mới Ngay',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _onRefresh, // Đổi thành _onRefresh
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.primaryColor.withOpacity(0.7),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
