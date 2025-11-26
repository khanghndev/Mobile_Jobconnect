import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension PlatformExtension on BuildContext {
  //  Android
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  //  iOS
  bool get isIOS => !kIsWeb && Platform.isIOS;

  //  Web
  bool get isWeb => kIsWeb;

  //  desktop (Windows, macOS, Linux)
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
