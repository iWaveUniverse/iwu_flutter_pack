import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 

import 'app_setup.dart'; 
  
double get _height => appSetup.appTextStyleWrap?.height ?? 1.2;
TextStyle _fontWrap({required TextStyle textStyle}) {
  if (appSetup.appTextStyleWrap?.fontWrap != null) {
    return appSetup.appTextStyleWrap!.fontWrap(textStyle);
  }
  return GoogleFonts.outfit(textStyle: textStyle);
}

TextStyle w100TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w100,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w200TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w200,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w300TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w400TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w500TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w600TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w700TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w800TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}

TextStyle w900TextStyle(
    {Color? color,
    FontStyle? fontStyle,
    double? height,
    double fontSize = 14,
    TextStyle? style,
    TextDecoration? decoration}) {
  return _fontWrap(
      textStyle: TextStyle(
              fontStyle: fontStyle,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: color ?? appColorText,
              decoration: decoration,
              height: height ?? _height)
          .merge(style));
}
