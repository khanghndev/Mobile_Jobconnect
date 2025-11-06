import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/notifications/widgets/notification/notification_app_bar.dart';
import 'package:job_connect/features/notifications/widgets/notification/notification_item.dart';
import 'package:job_connect/features/notifications/widgets/notification/notification_shimmer.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  final String idUser;
  const NotificationScreen({super.key, required this.idUser});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
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

    // Gọi ViewModel để load dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<NotificationViewModel>();
      await vm.getNotificationsByIdUser(widget.idUser);
      await vm.getUnreadCount(widget.idUser);

      _listAnimationController.forward();
      if (vm.unreadCount > 0) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<NotificationViewModel>(
      builder: (context, vm, child) {
        final notifications = vm.notifications;
        final isLoading = vm.isLoading;
        final selectMode = vm.selectMode;
        final selectedCount = vm.selectedNotifications.length;
        final unreadCount = vm.unreadCount;

        // Hiện / ẩn FAB dựa theo số lượng chưa đọc
        if (!isLoading && unreadCount > 0 && !selectMode) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: NotificationAppBar(
            isLoading: isLoading,
            selectMode: selectMode,
            unreadCount: unreadCount,
            selectedCount: selectedCount,
            totalCount: notifications.length,
            onBack: () => context.pop(true),
            onToggleSelectMode: vm.onToggleSelectMode,
            onMarkAsRead: selectedCount > 0 ? vm.markAsRead : null,
            onDeleteSelected: selectedCount > 0 ? vm.deleteNotifications : null,
          ),
          body: isLoading
              ? const Center(child: NotificationShimmer(itemCount: 10))
              : notifications.isEmpty
                ? BackgroundEmptyState(
                    isSearching: false,
                    onRefresh: () async {
                      await vm.getNotificationsByIdUser(widget.idUser);
                      await vm.getUnreadCount(widget.idUser);
                    },
                    title: "Hộp thư trống",
                    iconData: Icons.notifications_paused_outlined,
                    subTitle:
                        "Mọi thông báo quan trọng sẽ xuất hiện ở đây. Hãy kiểm tra thường xuyên nhé!",
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await vm.getNotificationsByIdUser(widget.idUser);
                      await vm.getUnreadCount(widget.idUser);
                    },
                    color: theme.primaryColor,
                    backgroundColor: theme.cardColor,
                    child: AnimationLimiter(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox.shrink(),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 425),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: NotificationItem(
                                  notification: notification,
                                  selectMode: selectMode,
                                  isSelected: vm.selectedNotifications.contains(notification.idNotification),
                                  theme: theme,
                                  onTap: () async {
                                    if (selectMode) {
                                      vm.onToggleSelect(
                                          notification.idNotification);
                                    } else {
                                      // Đánh dấu đã đọc khi mở chi tiết
                                      if (notification.isRead == 0) {
                                        vm.onToggleSelect(notification.idNotification);
                                        await vm.markAsRead();
                                      }
                                      if(context.mounted){
                                        context.push(
                                          '/notification/detail',
                                          extra: {
                                            'notification': notification,
                                            'iconData':_getIconForType(notification.type),
                                            'iconColor': _getColorForType(notification.type, theme),
                                          },
                                        );
                                      }
                                    }
                                  },
                                  onLongPress: () {
                                    if (!selectMode) {
                                      vm.onToggleSelectMode();
                                      vm.onToggleSelect(notification.idNotification);
                                    }
                                  },
                                  iconData: _getIconForType(notification.type),
                                  iconColor: _getColorForType(notification.type, theme),
                                  timeAgo: DateUtilsHelper.getTimeAgo(notification.createdAt),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          floatingActionButton: ScaleTransition(
            scale: _fabScaleAnimation,
            child: FloatingActionButton.extended(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              onPressed: vm.markAllAsRead,
              icon: Icon(Icons.done_all_rounded, size: 20.sp),
              label: const Text(
                "Đọc Tất Cả",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        );
      },
    );
  }
}