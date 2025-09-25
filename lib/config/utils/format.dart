import 'package:intl/intl.dart';

class FormatUtils {
  static String formattedDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatSalary(num salary) {
    if (salary >= 1000000) {
      final double salaryInMillions = salary / 1000000;
      final formatter = NumberFormat('#,##0.#', 'vi_VN');
      return '${formatter.format(salaryInMillions)} triệu VNĐ';
    } else {
      if (salary == 0) {
        return 'Lương thỏa thuận';
      }
      final formatter = NumberFormat('#,##0', 'vi_VN');
      return '${formatter.format(salary)} VNĐ';
    }
  }

  static String removeDiacritics(String input) {
    final diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'Á': 'A',
      'À': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'É': 'E',
      'È': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ế': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ố': 'O',
      'Ồ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ớ': 'O',
      'Ờ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ứ': 'U',
      'Ừ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  static String extractDistrictAndCity(String location) {
    // Tách chuỗi địa chỉ thành các phần dựa trên dấu phẩy
    List<String> parts = location.split(',');

    String district = '';
    String city = '';
    String industrialZone = '';

    // Duyệt qua các phần để tìm Quận, Thành phố và Khu công nghiệp
    for (String part in parts) {
      String trimmedPart =
          part.trim(); // Loại bỏ khoảng trắng thừa ở đầu và cuối

      if (trimmedPart.toLowerCase().contains('khu công nghiệp')) {
        industrialZone = trimmedPart;
      } else if (trimmedPart.startsWith('Quận')) {
        district = trimmedPart;
      } else if (trimmedPart.startsWith('Thành phố') ||
          trimmedPart.startsWith('Tỉnh') ||
          trimmedPart.startsWith('TP.')) {
        city = trimmedPart;
      }
    }

    // Kết hợp lại theo thứ tự ưu tiên
    if (industrialZone.isNotEmpty) {
      // Nếu có khu công nghiệp, kết hợp với thành phố nếu có
      if (city.isNotEmpty) {
        return '$industrialZone, $city';
      }
      return industrialZone;
    } else if (district.isNotEmpty && city.isNotEmpty) {
      return '$district, $city';
    } else if (district.isNotEmpty) {
      return district;
    } else if (city.isNotEmpty) {
      return city;
    } else {
      // Nếu không tìm thấy thông tin phù hợp, trả về phần đầu tiên của địa chỉ
      return parts.isNotEmpty ? parts[0].trim() : 'Không có thông tin địa chỉ';
    }
  }

  static String formatDuration(int durationInSeconds) {
    final int hours = (durationInSeconds / 3600).toInt();
    final int minutes = ((durationInSeconds % 3600) / 60).toInt();
    final int seconds = (durationInSeconds % 60).toInt();

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else if (minutes > 0) {
      return '$minutes:$seconds';
    } else {
      return '00:$seconds';
    }
  }
}
