import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class FilterDialogWidget extends StatelessWidget {

  const FilterDialogWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(Icons.filter_alt_outlined, color: Colors.black, size: 24.sp),
          SizedBox(width: 10.w),
          Text(
            'Lọc CV Nâng Cao',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
          ),
        ],
      ),
      content: const Text(
        'Tính năng lọc chi tiết theo ngành nghề, cấp bậc sẽ sớm được cập nhật. Hiện tại bạn có thể lọc theo loại file (PDF, Word) ở thanh bên dưới.',
        style: TextStyle(height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'ĐÃ HIỂU',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}