import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpDialogWidget extends StatelessWidget {
  const HelpDialogWidget({
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
          Icon(
            Icons.help_center_outlined,
            color: theme.colorScheme.secondary,
          ),
          SizedBox(width: 10.w),
          const Text(
            'Hướng Dẫn Sử Dụng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Chào mừng bạn đến với trang quản lý CV!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            SizedBox(height: 10),
            Text(
              ' • Tìm kiếm CV nhanh chóng bằng tên file.',
              style: TextStyle(height: 1.4),
            ),
            Text(
              ' • Lọc CV theo định dạng PDF hoặc Word.',
              style: TextStyle(height: 1.4),
            ),
            Text(
              ' • Nhấn vào một CV để xem nội dung chi tiết.',
              style: TextStyle(height: 1.4),
            ),
            Text(
              ' • Sử dụng menu (⋮) trên mỗi CV để: Chỉnh sửa tên, Chia sẻ link, Tải xuống thiết bị, hoặc Xóa CV.',
              style: TextStyle(height: 1.4),
            ),
            Text(
              ' • Nhấn nút "+" ở góc dưới để thêm CV mới: Tải lên từ máy, Tạo CV bằng AI (sắp ra mắt), hoặc Sử dụng các mẫu CV chuyên nghiệp có sẵn.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 10),
            Text(
              ' • Menu (⋮) ở góc trên cùng cho phép bạn: Sắp xếp danh sách CV hoặc xem lại hướng dẫn này.',
              style: TextStyle(height: 1.4),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'OKAY, TÔI HIỂU RỒI!',
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}