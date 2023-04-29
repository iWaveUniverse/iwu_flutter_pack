import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/extensions.dart';
import 'infinite_listview.dart';

typedef TextMapper = String Function(String numberText);

class TimeLinePicker extends StatefulWidget {
  final DateTime startDate;

  final int endDay;

  final int selectedDay;

  /// Min value user can pick

  /// Called when selected value changes
  final ValueChanged<DateTime> onChanged;

  /// Specifies how many items should be shown - defaults to 3
  final int itemCount;

  /// height of single item in pixels
  final double itemHeight;

  /// width of single item in pixels
  final double itemWidth;

  /// Direction of scrolling
  final Axis axis;

  /// Whether to trigger haptic pulses or not
  final bool haptics;

  /// Build the text of each item on the picker
  final TextMapper? textMapper;

  final bool infiniteLoop;

  final Duration selectedTimeDelay;

  final Widget Function(DateTime month) monthBuilder;

  final Widget Function(
      DateTime day, bool isSelected, double width, double height) dayBuilder;

  int? value;

  TimeLinePicker({
    Key? key,
    required this.startDate,
    required this.endDay,
    required this.selectedDay,
    required this.onChanged,
    required this.dayBuilder,
    required this.monthBuilder,
    this.itemCount = 3,
    this.itemHeight = 150,
    this.itemWidth = 100,
    this.axis = Axis.vertical,
    this.haptics = false,
    this.textMapper,
    this.infiniteLoop = false,
    this.selectedTimeDelay = const Duration(seconds: 8),
  })  : assert(endDay > 0),
        assert(endDay >= selectedDay),
        super(key: key) {
    value = selectedDay;
  }

  @override
  TimeLinePickerState createState() => TimeLinePickerState();
}

class TimeLinePickerState extends State<TimeLinePicker>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  late DateTime month;
  Timer? _timer;
  late int _oldSlectedValue;
  bool animatingTo = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _oldSlectedValue = widget.value!;
    month = widget.startDate.addDate(widget.selectedDay);
    final initialOffset = widget.selectedDay * itemExtent;
    if (widget.infiniteLoop) {
      _scrollController =
          InfiniteScrollController(initialScrollOffset: initialOffset);
    } else {
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
    }
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (animatingTo) return;
    var indexOfMiddleElement = (_scrollController.offset / itemExtent).round();
    if (widget.infiniteLoop) {
      indexOfMiddleElement %= itemCount;
    } else {
      indexOfMiddleElement = indexOfMiddleElement.clamp(0, itemCount - 1);
    }
    final intValueInTheMiddle =
        _intValueFromIndex(indexOfMiddleElement + additionalItemsOnEachSide);
    if (widget.value != intValueInTheMiddle) {
      widget.value = intValueInTheMiddle;
      setState(() {
        month = widget.startDate.add(Duration(days: intValueInTheMiddle));
      });
      if (widget.haptics) {
        HapticFeedback.selectionClick();
      }
    }
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _maybeCenterValue(),
    );
  }

  @override
  void didUpdateWidget(TimeLinePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _maybeCenterValue();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get isScrolling => _scrollController.position.isScrollingNotifier.value;

  double get itemExtent =>
      widget.axis == Axis.vertical ? widget.itemHeight : widget.itemWidth;

  int get itemCount => widget.endDay + 1;

  int get listItemsCount => itemCount + 2 * additionalItemsOnEachSide;

  int get additionalItemsOnEachSide => (widget.itemCount - 1) ~/ 2;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.monthBuilder(month),
        SizedBox(
          width: widget.axis == Axis.vertical
              ? widget.itemWidth
              : widget.itemCount * widget.itemWidth,
          height: widget.axis == Axis.vertical
              ? widget.itemCount * widget.itemHeight
              : widget.itemHeight,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (not) {
              if (not.dragDetails?.primaryVelocity == 0) {
                Future.microtask(() => _maybeCenterValue());
              }
              return true;
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.infiniteLoop)
                  InfiniteListView.builder(
                      scrollDirection: widget.axis,
                      controller: _scrollController as InfiniteScrollController,
                      itemExtent: itemExtent,
                      itemBuilder: _itemBuilder,
                      padding: EdgeInsets.zero)
                else
                  ListView.builder(
                    itemCount: listItemsCount,
                    scrollDirection: widget.axis,
                    controller: _scrollController,
                    itemExtent: itemExtent,
                    itemBuilder: _itemBuilder,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final value = _intValueFromIndex(index % itemCount);
    final dateValue = widget.startDate.add(Duration(days: value));
    final isExtra = !widget.infiniteLoop &&
        (index < additionalItemsOnEachSide ||
            index >= listItemsCount - additionalItemsOnEachSide);
    final isSelected = value == widget.value;

    if (isExtra) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (!isSelected) {
          setState(() {
            month = dateValue;
            widget.value = value;
          });
        }
        _maybeCenterValue(select: true);
      },
      child: SizedBox(
        width: widget.itemWidth,
        height: widget.itemHeight,
        child: widget.dayBuilder(
          dateValue,
          isSelected,
          widget.itemWidth,
          widget.itemHeight,
        ),
      ),
    );
  }

  setSelectedDate(DateTime date) {
    var newValue = date.dateDifference(widget.startDate);
    if (!isScrolling && widget.value != newValue && !animatingTo) {
      widget.value = newValue;
      _oldSlectedValue = widget.value!;
      _maybeCenterValue();
      month = date;
      setState(() {});
    }
  }

  String _getDisplayedValue(int value) {
    final text = widget.startDate.add(Duration(days: value)).day.toString();
    if (widget.textMapper != null) {
      return widget.textMapper!(text);
    } else {
      return text;
    }
  }

  int _intValueFromIndex(int index) {
    index -= additionalItemsOnEachSide;
    index %= itemCount;
    return index;
  }

  void _maybeCenterValue({bool select = false}) {
    if (_scrollController.hasClients && !isScrolling) {
      int index = widget
          .value!; //widget.startDate.addDate(widget.value!).dateDifference(widget.startDate);
      animatingTo = true;
      _scrollController
          .animateTo(
        index * itemExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      )
          .then((value) {
        animatingTo = false;
      });
      _timer?.cancel();
      if (select || widget.selectedTimeDelay.inSeconds == 0) {
        if (_oldSlectedValue != widget.value) {
          //_onDelayPageChanged(widget.value!);
          widget.onChanged(widget.startDate.addDate(widget.value!));
          _oldSlectedValue = widget.value!;
        }
      }
      if (!select && widget.selectedTimeDelay.inSeconds > 0) {
        _timer = Timer(widget.selectedTimeDelay, () {
          _scrollController.animateTo(
            _oldSlectedValue * itemExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        });
      }
    }
  }

  var _checkvalue = 0;
  Timer? _debounce;

  _onDelayPageChanged(int value) async {
    if (value == _checkvalue) {
      return;
    }
    _checkvalue = value;
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      widget.onChanged(widget.startDate.addDate(widget.value!));
    });
  }
}
