import 'package:flutter/foundation.dart';

abstract class PlatformInfo {
  bool get isAndroid;
  bool get isIOS;
  bool get isWeb;
  bool get isDesktop;
}

class PlatformInfoImpl implements PlatformInfo {
  const PlatformInfoImpl();

  @override
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get isWeb => kIsWeb;

  @override
  bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);
}
