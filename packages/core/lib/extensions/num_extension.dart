import 'package:flutter/material.dart';
import '../setup/index.dart';

class ScaleInheritedStateContainer extends InheritedWidget {
  final double scaleValue;

  static ScaleInheritedStateContainer? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScaleInheritedStateContainer>();
  }

  static ScaleInheritedStateContainer? of(BuildContext? context) {
    if (context != null) {
      final ScaleInheritedStateContainer? result = maybeOf(context);
      return result;
    }
    return null;
  }

  const ScaleInheritedStateContainer({
    Key? key,
    required this.scaleValue,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ScaleInheritedStateContainer oldWidget) =>
      scaleValue != oldWidget.scaleValue;
}

double get _scale => 1;

extension SizeExtension on num {
  double s() {
    return this *
        (ScaleInheritedStateContainer.of(findAppContext)?.scaleValue ?? _scale);
  }
}
