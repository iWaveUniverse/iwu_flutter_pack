import 'package:flutter/material.dart';

double scaleW(context, [double v = 1]) {
  if (context == null) return 1;
  if (MediaQuery.sizeOf(context).width >= 1280) return 1;
  return MediaQuery.sizeOf(context).width / 1280 * v;
}

T responsiveByWidth<T>(context, T size,
    {T? computer, T? tablet2, T? tablet1, T? phone}) {
  if (context == null) return size;
  if (ResponLayout.isComputer(context)) {
    return computer ?? size;
  }
  if (ResponLayout.isTablet2(context)) {
    return tablet2 ?? size;
  }
  if (ResponLayout.isTablet1(context)) {
    return tablet1 ?? size;
  }
  if (ResponLayout.isPhone(context)) {
    return phone ?? size;
  }
  return size;
}

bool isComputerByWidth(context) => ResponLayout.isComputer(context);
bool isPhoneByWidth(context) => ResponLayout.isPhone(context);
bool isTablet1ByWidth(context) => ResponLayout.isTablet1(context);

class ResponLayout extends StatelessWidget {
  final Widget phone;
  final Widget tablet1;
  final Widget tablet2;
  final Widget computer;

  const ResponLayout({
    super.key,
    required this.phone,
    required this.tablet1,
    required this.tablet2,
    required this.computer,
  });

  static const int phoneLimit = 480;
  static const int tabletLimit2 = 1280;
  static const int tabletLimit1 = 680;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneLimit;

  static bool isTablet1(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletLimit1 &&
      MediaQuery.sizeOf(context).width >= phoneLimit;

  static bool isTablet2(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletLimit2 &&
      MediaQuery.sizeOf(context).width >= tabletLimit1;

  static bool isComputer(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletLimit2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < phoneLimit) {
          return phone;
        } else if (constraints.maxWidth < tabletLimit1) {
          return tablet1;
        } else if (constraints.maxWidth < tabletLimit2) {
          return tablet2;
        } else {
          return computer;
        }
      },
    );
  }
}
