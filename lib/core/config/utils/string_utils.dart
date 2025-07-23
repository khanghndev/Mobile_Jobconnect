class StringUtils {
  /// Viết hoa chữ cái đầu tiên
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Loại bỏ khoảng trắng 2 đầu và thay thế nhiều khoảng trắng giữa bằng 1
  static String normalizeWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Kiểm tra chuỗi có phải là số hay không
  static bool isNumeric(String input) {
    return double.tryParse(input) != null;
  }

  /// Rút gọn chuỗi dài, thêm dấu "..."
  static String truncate(String input, int maxLength) {
    if (input.length <= maxLength) return input;
    return input.substring(0, maxLength) + '...';
  }

  /// Format tên: xóa khoảng trắng dư và viết hoa từng chữ (Title Case)
  static String formatName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((e) => capitalize(e.toLowerCase())).join(' ');
  }

  /// Kiểm tra chuỗi có trống hoặc toàn khoảng trắng không
  static bool isBlank(String? input) {
    return input == null || input.trim().isEmpty;
  }

  /// Ẩn email: ví dụ user@gmail.com -> u***@gmail.com
  static String obscureEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    final prefix = parts[0];
    return prefix[0] + '*' * (prefix.length - 1) + '@' + parts[1];
  }
}

// Cách sử dụng
// StringUtils.capitalize('hello world');       // Hello world
// StringUtils.formatName('  nguyen   van an'); // Nguyen Van An
// StringUtils.truncate('Lorem ipsum', 5);      // Lorem...
