import 'package:dash_flags/dash_flags.dart';
import 'package:flutter/material.dart';

class WidgetAppFlag extends StatelessWidget {
  final String? countryCode;
  final String? languageCode;
  final double height;
  final Widget? errorBuilder;
  final double radius;
  const WidgetAppFlag.languageCode({
    super.key,
    this.height = 24,
    this.errorBuilder,
    this.radius = 0,
    required this.languageCode,
  }) : countryCode = null;

  const WidgetAppFlag.countryCode({
    super.key,
    required this.countryCode,
    this.height = 24,
    this.errorBuilder,
    this.radius = 0,
  }) : languageCode = null;

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();
    if (languageCode != null) {
      child = LanguageFlag(
        language: Language.fromCode(languageCode!.toLowerCase()),
        height: height,
      );
    } else if (countryCode != null) {
      child = CountryFlag(
        country: Country.fromCode(countryCode!.toLowerCase()),
        height: height,
      );
    } else {
      child = errorBuilder ?? const SizedBox();
    }
    if (radius != 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }
    return child;
  }
}
