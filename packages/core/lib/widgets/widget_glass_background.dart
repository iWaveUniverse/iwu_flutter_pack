import 'dart:ui';

import 'package:flutter/material.dart';

class WidgetGlassBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? blur;
  final Border? border;

  const WidgetGlassBackground({
    Key? key,
    required this.child,
    this.margin,
    this.blur,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var blur = this.blur ?? 10.0;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: border,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              color: backgroundColor ?? Colors.grey.shade200.withOpacity(0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: margin ?? EdgeInsets.zero,
    //   child: ClipRRect(
    //     borderRadius: borderRadius ?? BorderRadius.circular(8),
    //     child: Stack(
    //       children: [
    //         Container(
    //           child: Opacity(
    //             opacity: 0,
    //             child: Container(
    //               padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //               child: child,
    //             ),
    //           ),
    //           decoration: new BoxDecoration(
    //             color: backgroundColor ?? Colors.grey.shade200.withOpacity(0.5),
    //           ),
    //         ),
    //         new BackdropFilter(
    //           filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    //           child: new Container(
    //             padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //             child: child,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
