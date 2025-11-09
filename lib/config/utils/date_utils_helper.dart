import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  /// Trả về chuỗi như: "5 phút", "2 giờ"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    Duration diff = now.difference(dateTime);

    // Trường hợp trong tương lai
    if (diff.isNegative) {
      diff = diff.abs();
      if (diff.inSeconds < 60) return 'Trong ${diff.inSeconds} giây';
      if (diff.inMinutes < 60) return 'Trong ${diff.inMinutes} phút';
      if (diff.inHours < 24) return 'Trong ${diff.inHours} giờ';
      if (diff.inDays < 7) return 'Trong ${diff.inDays} ngày';
      if (diff.inDays < 30) return 'Trong ${(diff.inDays / 7).floor()} tuần';
      if (diff.inDays < 365) return 'Trong ${(diff.inDays / 30).floor()} tháng';
      return 'Trong ${(diff.inDays / 365).floor()} năm';
    }

    // Trường hợp trong quá khứ
    if (diff.inSeconds < 60) return '${diff.inSeconds} giây';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';

    // Nếu hơn 7 ngày → hiển thị dạng ngày tháng giờ
    final dateFormat = DateFormat('d MMMM \'lúc\' HH:mm', 'vi_VN');
    return dateFormat.format(dateTime);
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

  static String getTimeAgo(DateTime dateTime) {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    return timeago.format(dateTime, locale: 'vi');
  }

}

// Cách sử dụng
// final now = DateTime.now();
// print(DateUtilsHelper.formatDate(now));         // 20/07/2025
// print(DateUtilsHelper.formatDateTime(now));     // 20/07/2025 14:12
// print(DateUtilsHelper.timeAgo(now.subtract(Duration(hours: 2))));  // 2 giờ

// print(DateUtilsHelper.isToday(DateTime.now()));  // true
// print(DateUtilsHelper.isYesterday(DateTime.now().subtract(Duration(days: 1))));  // true
