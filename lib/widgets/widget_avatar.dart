import 'package:flutter/material.dart'; 

import 'widget_app_image.dart';
import '../setup/index.dart';

class WidgetAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius1;
  final double radius2;
  final double radius3;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? errorAsset;
  final Function()? onTap;
  final bool isWithoutBorder;
  final Widget Function()? placeholderBuilder;

  const WidgetAvatar(
      {Key? key,
      required this.imageUrl,
      required this.radius1,
      required this.radius2,
      required this.radius3,
      this.placeholderBuilder,
      this.onTap,
      this.backgroundColor,
      this.errorAsset,
      this.borderColor})
      : isWithoutBorder = false,
        super(key: key);

  const WidgetAvatar.withoutBorder({
    Key? key,
    required this.imageUrl,
    required double radius,
    this.placeholderBuilder,
    this.onTap,
    this.errorAsset,
  })  : isWithoutBorder = true,
        radius1 = radius,
        radius2 = radius,
        radius3 = radius,
        borderColor = Colors.transparent,
        backgroundColor = Colors.transparent,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = WidgetAppImage(
      imageUrl: imageUrl,
      width: radius3 * 2,
      height: radius3 * 2,
      radius: radius3 * 2,
      placeholderWidget: placeholderBuilder?.call(),
      errorWidget: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(
          errorAsset ?? assetjpg('defaultavatar'),
          package: errorAsset != null ? null : '_private_core',
        ),
      ),
    );
    if (isWithoutBorder) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
                width: radius1 - radius2, color: borderColor ?? appColors.text),
            shape: BoxShape.circle),
        width: radius1 * 2,
        height: radius1 * 2,
        padding: EdgeInsets.all(radius2 - radius3),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
