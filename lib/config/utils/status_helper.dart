import 'dart:ui';

import 'package:flutter/material.dart';

class AppStatus {
  // Define API status keys
  static const String pending = 'pending';
  static const String interview = 'interview'; // or 'interview' if that's what your API uses
  static const String rejected = 'rejected';
  static const String accepted = 'accepted';
  static const String viewed = 'viewed';
  static const String unknown = 'unknown';

  // Map API status keys to display names, colors, and icons
  static Map<String, Map<String, dynamic>> displayConfig = {
    pending: {
      'text': 'Đã gửi NTD',
      'color': Colors.yellow.shade700,
      'bgColor': Colors.yellow.shade50,
      'icon': Icons.hourglass_top_rounded,
    },
    interview: {
      'text': 'Phỏng vấn',
      'color':  Colors.blue.shade700,
      'bgColor': Colors.blue.shade50,
      'icon': Icons.people_alt_rounded,
    },
    rejected: {
      'text': 'Từ chối',
      'color': Colors.red.shade700,
      'bgColor': Colors.red.shade50,
      'icon': Icons.cancel_rounded,
    },
    accepted: {
      'text': 'Đã nhận',
      'color': Colors.green.shade700,
      'bgColor': Colors.green.shade50,
      'icon': Icons.check_circle_rounded,
    },
    viewed: {
      'text': 'Đã xem',
      'color': Colors.grey.shade700,
      'bgColor': Colors.grey.shade200,
      'icon': Icons.timer_off_rounded,
    },
    unknown: {
      'text': 'Không rõ',
      'color': Colors.grey.shade700,
      'bgColor': Colors.grey.shade200,
      'icon': Icons.help_outline_rounded,
    },
  };

  static String getDisplayText(String apiStatus) {
    return displayConfig[apiStatus]?['text'] ??
        displayConfig[unknown]!['text']!;
  }

  static Color getTextColor(String apiStatus) {
    return displayConfig[apiStatus]?['color'] ??
        displayConfig[unknown]!['color']!;
  }

  static Color getBgColor(String apiStatus) {
    return displayConfig[apiStatus]?['bgColor'] ??
        displayConfig[unknown]!['bgColor']!;
  }

  static IconData getIcon(String apiStatus) {
    return displayConfig[apiStatus]?['icon'] ??
        displayConfig[unknown]!['icon']!;
  }

  static List<String> getAllApiStatuses() {
    return [pending, interview, accepted, rejected, viewed, unknown];
  }
}
