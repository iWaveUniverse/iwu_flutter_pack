import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../setup/index.dart';

enum GestureType { none, rightClick, onTap, longPress, hover }

class WidgetOverlayActions extends StatefulWidget {
  final Widget Function(Widget child)? backgroundBuilder;
  final Widget Function(Widget child, Size size, Offset childPosition,
      Offset? pointerPosition, double animationValue, Function hide) builder;
  final Widget? child;
  final Widget Function(bool isDropdownOpened)? childBuilder;
  final Duration duration;
  final GestureType gestureType;
  final ValueChanged<bool>? callback;
  final double inkwellBorderRadius;
  const WidgetOverlayActions({
    Key? key,
    this.duration = const Duration(milliseconds: 200),
    this.gestureType = GestureType.onTap,
    this.backgroundBuilder,
    this.callback,
    required this.builder,
    this.child,
    this.childBuilder,
    this.inkwellBorderRadius = 99,
  }) : super(key: key);

  @override
  State<WidgetOverlayActions> createState() => WidgetOverlayActionsState();
}

class WidgetOverlayActionsState extends State<WidgetOverlayActions>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  GlobalKey dropdownKey = GlobalKey();
  OverlayEntry? floatingDropdown;
  ValueNotifier<bool> isDropdownOpened = ValueNotifier(false);
  Offset? pointerPosition;

  Widget get _child => widget.childBuilder != null
      ? ValueListenableBuilder(
          valueListenable: isDropdownOpened,
          builder: (_, value, child) =>
              widget.childBuilder!(isDropdownOpened.value))
      : widget.child!;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      lowerBound: .0001,
      upperBound: 1,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
  }

  OverlayEntry _createFloatingDropdown() {
    animationController.forward();
    RenderBox box =
        dropdownKey.currentContext!.findRenderObject()! as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    Widget child = AnimatedBuilder(
      animation: animationController,
      builder: (_, child) {
        return FadeTransition(
          opacity: animationController,
          child: Stack(
            children: [
              widget.builder(_child, box.size, position, pointerPosition,
                  animationController.value, hideMenu),
            ],
          ),
        );
      },
    );
    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: hideMenu, 
          child: Material(
            color: Colors.transparent,
            child: widget.backgroundBuilder != null
                ? widget.backgroundBuilder!(child)
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                    child: child,
                  ),
          ),
        );
      },
    );
  }

  void hideMenu() async {
    await animationController.reverse();
    floatingDropdown?.remove();
    isDropdownOpened.value = !isDropdownOpened.value;
    widget.callback?.call(isDropdownOpened.value);
  }

  void showMenu() {
    if (!isDropdownOpened.value) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        floatingDropdown = _createFloatingDropdown();
        Overlay.of(context).insert(floatingDropdown!);
        isDropdownOpened.value = !isDropdownOpened.value;
      });
      appHaptic();
    }
    widget.callback?.call(isDropdownOpened.value);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.gestureType) {
      case GestureType.none:
        return Container(key: dropdownKey, child: _child);
      case GestureType.rightClick:
        return Listener(
          child: Container(key: dropdownKey, child: _child),
          onPointerDown: (PointerDownEvent event) async {
            if (event.kind == PointerDeviceKind.mouse &&
                event.buttons == kSecondaryMouseButton) {
              pointerPosition = event.position;
              showMenu();
            }
          },
        );
      case GestureType.longPress:
        return InkWell(
            key: dropdownKey,
            onLongPress: showMenu,
            onTapDown: (details) {
              pointerPosition = details.globalPosition;
            },
            borderRadius: BorderRadius.circular(widget.inkwellBorderRadius),
            child: _child);
      case GestureType.hover:
        return InkWell(
            key: dropdownKey,
            onTapDown: (details) {
              pointerPosition = details.globalPosition;
            },
            borderRadius: BorderRadius.circular(widget.inkwellBorderRadius),
            onHover: (value) {
              if (value) {
                showMenu();
              }
            },
            child: _child);
      default:
        return InkWell(
          key: dropdownKey,
          onTap: showMenu,
          onTapDown: (details) {
            pointerPosition = details.globalPosition;
          },
          borderRadius: BorderRadius.circular(widget.inkwellBorderRadius),
          child: _child,
        );
    }
  }
}
