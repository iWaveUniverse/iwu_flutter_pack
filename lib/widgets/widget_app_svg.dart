import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../setup/index.dart'; 

class WidgetAppSVG extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final String? package;
  const WidgetAppSVG(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.package,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset.startsWith('assets/') ? asset : assetsvg(asset),
      package: package,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
