import 'package:flutter/material.dart';

IconData getAdaptiveBackIcon(BuildContext context) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  if (isIOS) {
    return Icons.arrow_back_ios_new;
  }
  // return Icons.arrow_back;
  return Icons.arrow_back_ios_new;
}
