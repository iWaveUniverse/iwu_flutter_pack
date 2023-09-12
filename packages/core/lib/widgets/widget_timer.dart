import 'dart:async';

import 'package:flutter/material.dart';

class WidgetTimer extends StatefulWidget {
  final Widget Function() builder;
  final Duration duration;
  const WidgetTimer(
      {Key? key,
      required this.builder,
      this.duration = const Duration(seconds: 1)})
      : super(key: key);

  @override
  _WidgetTimerState createState() => _WidgetTimerState();
}

class _WidgetTimerState extends State<WidgetTimer> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}
