import 'package:intl/intl.dart';

class DateUtilsHelper {
  /// Chuyển DateTime thành chuỗi định dạng dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Chuyển DateTime thành chuỗi có giờ: dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Chuyển string thành DateTime với định dạng cụ thể
  static DateTime parseDate(String dateStr, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).parse(dateStr);
  }

  /// Trả về chuỗi như: "5 phút trước", "2 giờ trước"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds} giây trước';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} tháng trước';
    return '${(diff.inDays / 365).floor()} năm trước';
  }

  /// Kiểm tra hôm nay
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  /// Kiểm tra ngày hôm qua
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

// Cách sử dụng
// final now = DateTime.now();
// print(DateUtilsHelper.formatDate(now));         // 20/07/2025
// print(DateUtilsHelper.formatDateTime(now));     // 20/07/2025 14:12
// print(DateUtilsHelper.timeAgo(now.subtract(Duration(hours: 2))));  // 2 giờ trước

// print(DateUtilsHelper.isToday(DateTime.now()));  // true
// print(DateUtilsHelper.isYesterday(DateTime.now().subtract(Duration(days: 1))));  // true
