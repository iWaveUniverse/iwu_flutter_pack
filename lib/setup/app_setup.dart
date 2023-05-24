import 'package:flutter/material.dart';

import 'app_base.dart';

AppSetup get appSetup => AppSetup._instance;
AppColorsBase get appColors => appSetup.appColors;
AppPrefsBase get appPrefs => appSetup.appPrefs;

Color get appColorPrimary => appSetup.appColors.primary;
Color get appColorBackground => appSetup.appColors.background;
Color get appColorElement => appSetup.appColors.element;
Color get appColorText => appSetup.appColors.text;

BuildContext? get findAppContext => appSetup.findAppContext?.call();

class AppSetup {
  static late AppSetup _instance;
  static initialized({required AppSetup value}) {
    _instance = value;
  }

  AppEnv env;
  AppPrefsBase appPrefs;
  AppColorsBase appColors;
  AppTextStyleWrap? appTextStyleWrap;
  BuildContext? Function()? findAppContext;

  AppSetup({
    required this.env,
    required this.appPrefs,
    required this.appColors,
    this.appTextStyleWrap,
    this.findAppContext,
  });

  AppSetup copyWith({
    AppEnv? env,
    AppPrefsBase? appPrefs,
    AppColorsBase? appColors,
    AppTextStyleWrap? appTextStyleWrap,
    BuildContext? Function()? findAppContext,
  }) {
    return AppSetup(
      env: env ?? this.env,
      appPrefs: appPrefs ?? this.appPrefs,
      appColors: appColors ?? this.appColors,
      appTextStyleWrap: appTextStyleWrap ?? this.appTextStyleWrap,
      findAppContext: findAppContext ?? this.findAppContext,
    );
  }

  @override
  String toString() {
    return 'AppSetup(env: $env, appPrefs: $appPrefs, appColors: $appColors, appTextStyleWrap: $appTextStyleWrap)';
  }

  @override
  bool operator ==(covariant AppSetup other) {
    if (identical(this, other)) return true;

    return other.env == env &&
        other.appPrefs == appPrefs &&
        other.appColors == appColors &&
        other.appTextStyleWrap == appTextStyleWrap;
  }

  @override
  int get hashCode {
    return env.hashCode ^
        appPrefs.hashCode ^
        appColors.hashCode ^
        appTextStyleWrap.hashCode;
  }
}
