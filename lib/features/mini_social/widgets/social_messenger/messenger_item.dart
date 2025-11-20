import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';
import 'package:job_connect/config/utils/image_url.dart';

class MessengerItem extends StatefulWidget {
  final MessageModel msg;
  final String? name;
  final String? avatarUrl;
  final int? unreadCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool? isAi;

  const MessengerItem({
    super.key,
    required this.msg,
    required this.onTap,
    this.onDelete,
    this.name,
    this.avatarUrl,
    this.unreadCount,
    this.isAi,
  });

  @override
  State<MessengerItem> createState() => _MessengerItemState();
}

class _MessengerItemState extends State<MessengerItem> {
  bool _showDelete = false;

  void _toggleDelete() {
    setState(() {
      _showDelete = !_showDelete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onDelete != null ? _toggleDelete : null,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            padding: EdgeInsets.only(right: _showDelete ? 50.w : 0),
            child: ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundImage: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                        ? (widget.isAi == true
                            ? AssetImage(widget.avatarUrl ?? AppImages.ai)
                            : ImageUtils.getImageProvider(widget.avatarUrl!))
                        : null,
                    backgroundColor: Colors.grey.withValues( alpha: 0.1),
                    child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                        ? Icon(Icons.person, color: theme.colorScheme.onBackground)
                        : null,
                  ),
                  if ((widget.unreadCount ?? 0) > 0)
                    Positioned(
                      right: -2.w,
                      top: -2.h,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.h,
                        ),
                        child: Center(
                          child: Text(
                            "${widget.unreadCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                widget.name ?? widget.msg.idSender,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              subtitle: Text(
                widget.msg.content,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  color: Colors.black,
                  fontWeight: widget.msg.isRead == false
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (_showDelete && widget.onDelete != null)
            Positioned(
              right: 10.w,
              child: GestureDetector(
                onTap: () {
                  widget.onDelete!();
                  _toggleDelete();
                },
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }
}