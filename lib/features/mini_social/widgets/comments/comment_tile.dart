import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class CommentTile extends StatelessWidget {
  final String username;
  final String textContent;
  final String time;
  final String icon;
  final int count;
  final String avatarUrl;
  final VoidCallback onReplyTap;
  final VoidCallback onReactTap;
  final VoidCallback? onUserTap;

  const CommentTile({
    super.key,
    required this.username,
    required this.textContent,
    required this.time,
    required this.icon,
    required this.count,
    required this.avatarUrl,
    required this.onReplyTap,
    required this.onReactTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onUserTap,
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: ImageUtils.getImageProvider(avatarUrl),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: onUserTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 1, // độ dày border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  child: RichText(
                    text: TextSpan(
                      text: "$username  ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: textContent,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: onReactTap,
                    child: Text(
                      "Thích",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Text(
                      "Trả lời",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                  const Spacer(),
                  if (count > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Text(icon, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp)),
                          SizedBox(width: 2.w),
                          Text('$count', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}