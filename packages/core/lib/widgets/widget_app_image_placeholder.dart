import 'package:flutter/material.dart'; 

import '../setup/index.dart';
import 'shimmer.dart';

class WidgetAppImagePlaceHolder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  const WidgetAppImagePlaceHolder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetAppShimmer(
      width: width,
      height: height,
    );
  }
}

class WidgetAppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  const WidgetAppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  Color get baseColor => appColors.shimmerBaseColor ;

  Color get highlightColor => appColors.shimerHighlightColor  ;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width ?? 999,
        height: height ?? 999,
        decoration: BoxDecoration(color: baseColor, borderRadius: borderRadius),
      ),
    );
  }
}
