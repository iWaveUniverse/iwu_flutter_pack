import 'package:flutter/material.dart';

enum AppEnv { preprod, prod }

abstract class AppPrefsBase {
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
  double? height;

  AppTextStyleWrap({required this.fontWrap, this.height = 1.2});
}
