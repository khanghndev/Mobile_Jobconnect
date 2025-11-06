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
    return '${input.substring(0, maxLength)}...';
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
    return '${prefix[0]}${'*' * (prefix.length - 1)}@${parts[1]}';
  }

  /// Loại bỏ dấu
  static String removeDiacritics(String input) {
    final diacriticsMap = {
      'á': 'a', 'à': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
      'ă': 'a', 'ắ': 'a', 'ằ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
      'â': 'a', 'ấ': 'a', 'ầ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
      'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
      'ê': 'e', 'ế': 'e', 'ề': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
      'í': 'i', 'ì': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
      'ó': 'o', 'ò': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
      'ô': 'o', 'ố': 'o', 'ồ': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
      'ơ': 'o', 'ớ': 'o', 'ờ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
      'ú': 'u', 'ù': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
      'ư': 'u', 'ứ': 'u', 'ừ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
      'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
      'đ': 'd',
      'Á': 'A', 'À': 'A', 'Ả': 'A', 'Ã': 'A', 'Ạ': 'A',
      'Ă': 'A', 'Ắ': 'A', 'Ằ': 'A', 'Ẳ': 'A', 'Ẵ': 'A', 'Ặ': 'A',
      'Â': 'A', 'Ấ': 'A', 'Ầ': 'A', 'Ẩ': 'A', 'Ẫ': 'A', 'Ậ': 'A',
      'É': 'E', 'È': 'E', 'Ẻ': 'E', 'Ẽ': 'E', 'Ẹ': 'E',
      'Ê': 'E', 'Ế': 'E', 'Ề': 'E', 'Ể': 'E', 'Ễ': 'E', 'Ệ': 'E',
      'Í': 'I', 'Ì': 'I', 'Ỉ': 'I', 'Ĩ': 'I', 'Ị': 'I',
      'Ó': 'O', 'Ò': 'O', 'Ỏ': 'O', 'Õ': 'O', 'Ọ': 'O',
      'Ô': 'O', 'Ố': 'O', 'Ồ': 'O', 'Ổ': 'O', 'Ỗ': 'O', 'Ộ': 'O',
      'Ơ': 'O', 'Ớ': 'O', 'Ờ': 'O', 'Ở': 'O', 'Ỡ': 'O', 'Ợ': 'O',
      'Ú': 'U', 'Ù': 'U', 'Ủ': 'U', 'Ũ': 'U', 'Ụ': 'U',
      'Ư': 'U', 'Ứ': 'U', 'Ừ': 'U', 'Ử': 'U', 'Ữ': 'U', 'Ự': 'U',
      'Ý': 'Y', 'Ỳ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y', 'Ỵ': 'Y',
      'Đ': 'D',
    };
    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  // Cắt chuỗi /../.../
  static String extractFileName(String path) {
    return path.split('/').last;
  }

}

// Cách sử dụng
// StringUtils.capitalize('hello world');       // Hello world
// StringUtils.formatName('  nguyen   van an'); // Nguyen Van An
// StringUtils.truncate('Lorem ipsum', 5);      // Lorem...
// StringUtils.removeDiacritics('Tiến);         // Tien
