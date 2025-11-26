import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:go_router/go_router.dart';

class NotificationIcon extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final bool isRecruiter;

  const NotificationIcon({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    this.isRecruiter = false,
  });

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);
    final primaryColor = widget.isRecruiter ? recruiterPrimary : theme.colorScheme.primary;
    
    return Consumer<NotificationViewModel>(
      builder: (context, vm, _) {
        final count = vm.unreadCount;
        final hasUnread = count > 0;
        final showDot = count >= 10;

        return GestureDetector(
          onTap: () => context.push(
            '/notification',
            extra: {'idUser': widget.idUser},
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(4.r),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(
                      '/notification',
                      extra: {'idUser': widget.idUser},
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: primaryColor,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isLoggedIn && hasUnread)
                Positioned(
                  right: 5.w,
                  top: 5.h,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.7, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      padding: showDot
                          ? EdgeInsets.zero
                          : EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: showDot
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: showDot
                            ? null
                            : BorderRadius.circular(10.r),
                        border: Border.all(
                          color: theme.cardColor,
                          width: 1.5.w,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: showDot ? 10.w : 20.w,
                        minHeight: showDot ? 10.w : 20.w,
                      ),
                      alignment: Alignment.center,
                      child: showDot
                          ? null
                          : Text(
                              '$count',
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}