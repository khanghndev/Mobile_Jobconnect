import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension PlatformExtension on BuildContext {
  //TODO: Android
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  //TODO: iOS
  bool get isIOS => !kIsWeb && Platform.isIOS;

  //TODO: Web
  bool get isWeb => kIsWeb;

  //TODO: desktop (Windows, macOS, Linux)
  bool get isDesktop =>
      !kIsWeb &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  String get platformName {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isDesktop) return 'desktop';
    return 'unknown';
  }
}
