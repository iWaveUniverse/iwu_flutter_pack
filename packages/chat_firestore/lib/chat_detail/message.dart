import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

enum MessageIndexOfGroup { top, bottom, center, none }

enum MessageType { text, image, audio, video, location, gif, lottie, custom }

class Message {
  Message({
    required this.widgetMessageOwner,
    required this.timestamp,
    required this.animationController,
    this.doc,
    this.tmpDoc,
  });

  final Widget Function(List<Message>) widgetMessageOwner;
  final int timestamp;
  final AnimationController animationController;
  Map<String, dynamic>? tmpDoc;
  DocumentSnapshot? doc;

  Map<String, dynamic> get data =>
      tmpDoc ?? Map.from(doc!.data() as Map<String, dynamic>);

  static Widget wrapMessage({
    required dynamic child,
    required AnimationController animationController,
  }) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: child,
    );
  }
}

///Seen state
class SeenState extends ValueNotifier<Map<String, dynamic>> {
  SeenState(value) : super(value);
}

///Reaction state
class ReactionState extends ValueNotifier {
  ReactionState(value) : super(value);
}

class MessageStateProvider extends StatefulWidget {
  const MessageStateProvider({
    super.key,
    this.child,
    required this.seenState,
    required this.reactionState,
  });
  final SeenState seenState;
  final ReactionState reactionState;
  final Widget? child;

  static SeenState seenStateOf(BuildContext context) {
    _MessageInheritedProvider? p = context.dependOnInheritedWidgetOfExactType(
        aspect: _MessageInheritedProvider);
    return p!.seen;
  }

  static ReactionState reactionStateOf(BuildContext context) {
    _MessageInheritedProvider? p = context.dependOnInheritedWidgetOfExactType(
        aspect: _MessageInheritedProvider);
    return p!.reaction;
  }

  @override
  State<StatefulWidget> createState() => _MessageStateProviderState();
}

class _MessageStateProviderState extends State<MessageStateProvider> {
  @override
  initState() {
    super.initState();
    widget.seenState.addListener(didValueChange);
    widget.reactionState.addListener(didValueChange);
  }

  didValueChange() {
    if (mounted) setState(() {});
  }

  @override
  dispose() {
    widget.seenState.removeListener(didValueChange);
    widget.reactionState.removeListener(didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MessageInheritedProvider(
      seen: widget.seenState,
      reaction: widget.reactionState,
      child: widget.child!,
    );
  }
}

class _MessageInheritedProvider extends InheritedWidget {
  _MessageInheritedProvider(
      {required this.seen, required this.reaction, required this.child})
      : _dataValue1 = seen.value,
        _dataValue2 = seen.value,
        super(child: child);
  final SeenState seen;
  final ReactionState reaction;
  final Map _dataValue1;
  final Map _dataValue2;

  @override
  final Widget child;

  @override
  bool updateShouldNotify(_MessageInheritedProvider oldWidget) {
    return _dataValue1 != oldWidget._dataValue1 ||
        _dataValue2 != oldWidget._dataValue2;
  }
}
