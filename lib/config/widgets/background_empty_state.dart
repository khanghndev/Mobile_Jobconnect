import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackgroundEmptyState extends StatelessWidget {
  final bool? isSearching;
  final VoidCallback onRefresh;
  final String title;
  final IconData iconData;
  final String? subTitle;
  final double? padding;

  const BackgroundEmptyState({
    super.key,
    this.isSearching = false,
    required this.onRefresh, 
    required this.title, 
    required this.iconData, 
    this.subTitle,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding ?? 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching == true
                  ? Icons.search_off_rounded
                  : iconData,
              size: 80.sp, // scale icon size
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: 24.h),
            Text(
              isSearching == true
                  ? "Không Tìm Thấy $title"
                  : "Chưa Có Dữ Liệu $title",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 22.sp, // scale font size
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              isSearching == true
                  ? subTitle ?? "Vui lòng thử lại với từ khóa tìm kiếm khác hoặc kiểm tra kết nối mạng."
                  : subTitle ?? "Chúng tôi đang cập nhật dữ liệu. Vui lòng quay lại sau hoặc thử làm mới.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.5,
                fontSize: 14.sp, 
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                isSearching == true ? "Xóa Tìm Kiếm & Làm Mới" : "Làm Mới Danh Sách",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 13.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
