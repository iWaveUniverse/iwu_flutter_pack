import 'package:flutter/material.dart';

import '../setup/index.dart';

class WidgetAssetImage extends StatelessWidget {
  final String _name;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final String? package;
  final BorderRadius? borderRadius;

  const WidgetAssetImage(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = name;

  WidgetAssetImage.png(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = assetpng(name);

  WidgetAssetImage.jpg(String name,
      {super.key,
      this.width,
      this.height,
      this.color,
      this.fit,
      this.package,
      this.borderRadius})
      : _name = assetjpg(name);

  Widget get image => Image.asset(
        _name,
        width: width,
        height: height,
        color: color,
        fit: fit,
      );

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}
