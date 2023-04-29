import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../setup/index.dart';

class WidgetAppLottie extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? package;
  final bool? repeat;
  final Animation<double>? controller;
  const WidgetAppLottie(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.package,
    this.repeat,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset.startsWith('assets/') ? asset : assetlottie(asset),
      controller: controller,
      package: package,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
    );
  }
}
