import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

enum AnimationStaggeredType { leftToRight, rightToLeft, bottomToTop, topToBottom }

class WidgetAnimationStaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final AnimationStaggeredType type;

  const WidgetAnimationStaggeredItem(
      {required this.index,
      required this.child,
      this.type = AnimationStaggeredType.leftToRight,
      this.duration});

  @override
  Widget build(BuildContext context) {
    Widget _child;
    switch (type) {
      case AnimationStaggeredType.leftToRight:
        _child = SlideAnimation(
          horizontalOffset: -50.0,
          child: FadeInAnimation(child: child),
        );
        break;
      case AnimationStaggeredType.rightToLeft:
        _child = SlideAnimation(
          horizontalOffset: 50.0,
          child: FadeInAnimation(child: child),
        );
        break;
      case AnimationStaggeredType.bottomToTop:
        _child = SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(child: child),
        );
        break;
      case AnimationStaggeredType.topToBottom:
        _child = SlideAnimation(
          verticalOffset: -50.0,
          child: FadeInAnimation(child: child),
        );
        break;
    }
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration ?? const Duration(milliseconds: 750),
      child: _child,
    );
  }
}
