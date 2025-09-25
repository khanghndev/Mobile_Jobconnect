import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/report_post/glass_card.dart';

class HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String author;
  final String? thumbnailUrl;

  const HeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.author,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: thumbnailUrl != null
                ? Image.network(
                    thumbnailUrl!,
                    width: 64.w,
                    height: 64.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbFallback(),
                  )
                : _thumbFallback(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 14.sp, color: theme.hintColor),
                    SizedBox(width: 4.w),
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _thumbFallback() => Container(
    width: 64.w,
    height: 64.w,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.r),
      gradient: const LinearGradient(
        colors: [Color(0xFFDEE8FF), Color(0xFFD6FFF3)],
      ),
    ),
    child: Icon(Icons.article_rounded, size: 28.sp, color: Colors.black54),
  );
}
