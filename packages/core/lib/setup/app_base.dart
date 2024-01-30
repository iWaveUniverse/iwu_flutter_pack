import 'package:flutter/material.dart';

enum AppEnv { preprod, prod }

abstract class AppPrefsBase {
  static String accessTokenKey = "accessToken";
  static String refreshTokenKey = "refreshToken";
  static String themeModeKey = "themeMode";
  static String themeModeDarkKey = "themeModeDark";
  static String themeModeLightKey = "themeModeLight";
  static String languageCodeKey = "languageCode";

  set languageCode(String? value);
  String? get languageCode;

  set dateFormat(String value);
  String get dateFormat;

  set timeFormat(String value);
  String get timeFormat;
}

abstract class AppColorsBase {
  Color get primary;

  Color get background;

  Color get element;

  Color get text;

  //Shimmer for image placeholder
  Color get shimmerBaseColor;

  Color get shimerHighlightColor;
}

class AppTextStyleWrap {
  TextStyle Function(TextStyle style) fontWrap;
  double Function()? fontSize;
  double Function()? height;

  AppTextStyleWrap({
    required this.fontWrap,
    this.height,
    this.fontSize,
  });
}

abstract class PNetworkOptions {
  final String baseUrl;
  final String baseUrlAsset;
  final String? mqttUrl;
  final int? mqttPort;

  String appImageCorrectUrl(String url, {base}) {
    if (url.trim().indexOf('http') != 0) {
      if ((base ?? baseUrlAsset ?? '').endsWith('/')) {
        if (url.startsWith('/')) {
          return (base ?? baseUrlAsset ?? '') + url.substring(1);
        } else {
          return (base ?? baseUrlAsset ?? '') + url;
        }
      } else {
        if (url.startsWith('/')) {
          return (base ?? baseUrlAsset ?? '') + url;
        } else {
          return (base ?? baseUrlAsset ?? '') + '/' + url;
        }
      }
    }
    return url;
  }

  PNetworkOptions({
    required this.baseUrl,
    required this.baseUrlAsset,
    this.mqttUrl,
    this.mqttPort,
  });

  @override
  String toString() {
    return 'PNetworkOptions(baseUrl: $baseUrl, baseUrlAsset: $baseUrlAsset, mqttUrl: $mqttUrl, mqttPort: $mqttPort)';
  }
}

class PNetworkOptionsOther extends PNetworkOptions {
  PNetworkOptionsOther({super.baseUrl = '', super.baseUrlAsset = ''});
}
