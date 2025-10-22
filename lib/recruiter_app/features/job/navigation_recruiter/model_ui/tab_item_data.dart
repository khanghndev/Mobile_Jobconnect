import 'package:flutter/material.dart';

class TabItemData {
  final Widget screen;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final bool isSpecial;

  const TabItemData({
    required this.screen,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    this.isSpecial = false,
  });
}