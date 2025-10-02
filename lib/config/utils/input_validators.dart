import 'package:flutter/material.dart';
import 'dart:core';

import 'package:intl/intl.dart';

class InputValidators {
  static bool isEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  static bool isPhone(String input) {
    // Loại bỏ khoảng trắng trước khi check
    final cleaned = input.replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(0[0-9]{9,10})$'); 
    return phoneRegex.hasMatch(cleaned);
  }

  static String? validate({
    required String? value,
    required String? hintText,
    TextInputType? keyboardType,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (hintText?.toLowerCase().contains('số điện thoại và email') == true) {
        return 'Số điện thoại/Email không được bỏ trống';
      }
      return '$hintText không được bỏ trống';
    }

    final val = value.trim();

    // Kiểm tra số điện thoại
    if (keyboardType == TextInputType.phone) {
      final cleanedPhone = val.replaceAll(' ', '');
      final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
      if (!phoneRegex.hasMatch(cleanedPhone))
        return 'Số điện thoại không hợp lệ';
    }

    // Kiểm tra email chỉ nhận gmail.com
    if (keyboardType == TextInputType.emailAddress) {
      final emailRegex = RegExp(r'^[\w.-]+@gmail\.com$');
      if (!emailRegex.hasMatch(val)) return 'Email không hợp lệ';
    }

    // Kiểm tra họ tên
    if (hintText?.toLowerCase().contains('họ và tên') == true) {
      final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
      if (!nameRegex.hasMatch(val)) {
        return 'Họ tên không được chứa ký tự đặc biệt hoặc số';
      }
    }

    // // Kiểm tra mật khẩu
    // if (hintText?.toLowerCase().contains('mật khẩu') == true) {
    //   if (val.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    // }

    // Kiểm tra ngày sinh
    if (hintText?.toLowerCase().contains('ngày sinh') == true) {
      try {
        final parsed = DateFormat("dd/MM/yyyy").parseStrict(val);
        if (parsed.isAfter(DateTime.now())) {
          return 'Ngày sinh không được lớn hơn ngày hiện tại';
        }
      } catch (_) {
        return 'Ngày sinh không hợp lệ';
      }
    }

    return null;
  }

  static String? validatePhoneOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại/Email không được bỏ trống';
    }

    final val = value.trim();

    // Regex cho số điện thoại VN (đã loại bỏ khoảng trắng)
    final cleanedPhone = val.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');

    // Regex cho email
    final emailRegex = RegExp(r'^[\w.-]+@gmail\.com$');

    if (val.contains('@')) {
      // Nếu có @ thì kiểm tra email
      if (!emailRegex.hasMatch(val)) {
        return 'Email không hợp lệ';
      }
    } else {
      // Không có @
      final firstChar = val[0];
      final startsWithLetter = RegExp(r'[a-zA-Z]');
      if (startsWithLetter.hasMatch(firstChar)) {
        // Bắt đầu bằng ký tự chữ mà không có @ -> báo lỗi email
        return 'Email không hợp lệ';
      }
      // Kiểm tra số điện thoại
      if (!phoneRegex.hasMatch(cleanedPhone)) {
        return 'Số điện thoại không hợp lệ';
      }
    }

    return null; // hợp lệ
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null; 
  }

  static String? validateConfirmPassword(
      String? confirmPasswordValue, String? newPasswordValue) {
    if (confirmPasswordValue == null || confirmPasswordValue.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (confirmPasswordValue != newPasswordValue) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null; 
  }
}
