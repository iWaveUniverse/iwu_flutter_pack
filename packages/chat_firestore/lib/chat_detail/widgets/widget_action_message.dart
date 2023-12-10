import 'dart:async';

import 'package:_iwu_pack_chat_firestore/constant.dart';
import 'package:_iwu_pack_chat_firestore/options.dart';
import 'package:_private_core/_private_core.dart';
import 'package:_private_core/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:_iwu_pack_chat_firestore/chat_detail/message.dart';
import 'package:_iwu_pack_chat_firestore/chat_detail/widgets/widget_message_content.dart';
import 'package:_iwu_pack_chat_firestore/_iwu_pack_chat_firestore.dart';
import 'package:_iwu_pack_chat_firestore/utils/utils.dart';

class WidgetActionsMessage extends StatefulWidget {
  final dynamic data;
  final Widget child;
  final bool Function(bool isMe)? isEnableDelete;
  final bool Function(bool isMe)? isEnableReply;
  final Widget Function({Widget child, VoidCallback onTap})? wrapCopyBuilder;
  const WidgetActionsMessage({
    Key? key,
    required this.child,
    required this.data,
    this.wrapCopyBuilder,
    this.isEnableDelete,
    this.isEnableReply,
  }) : super(key: key);

  @override
  State<WidgetActionsMessage> createState() => _WidgetActionsMessageState();
}

class _WidgetActionsMessageState extends State<WidgetActionsMessage> {
  int get timestamp => widget.data[kDbTIMESTAMP];
  bool get isMe => widget.data[kDbFROM] == loggedFirebaseId;
  BorderRadius get borderRadius => BorderRadius.circular(12);

  bool get inputLocked => chatDetailBloc.state.defaultMessage?.lockAction == 1;
  bool get isEnableCopyEdit =>
      widget.data[kDbMESSAGETYPE] == MessageType.text.index && isMe;
  bool get isEnableReply => widget.isEnableReply?.call(isMe) ?? true;
  bool get isEnableDelete => widget.isEnableDelete?.call(isMe) ?? isMe;
  bool get isImage => widget.data[kDbMESSAGETYPE] == MessageType.image.index;

  double get widthSizeAction => 8 * 3.0 + 32 * chatEmojiRectionAssets.length;

  ValueNotifier isHover = ValueNotifier(true);
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return WidgetOverlayActions(
      gestureType: kIsWeb ? GestureType.rightClick : GestureType.longPress,
      builder: (child, size, childPosition, pointerPosition, animationValue,
          hide, context) {
        if (MediaQuery.sizeOf(context).width <
            pointerPosition!.dx + widthSizeAction * 1.05) {
          return Positioned(
            top: pointerPosition.dy + 4,
            right: 24,
            child: Transform.scale(
                scale: animationValue,
                alignment: Alignment.topRight,
                child: _buildActions(hide)),
          );
        } else {
          return Positioned(
            top: pointerPosition.dy + 4,
            left: pointerPosition.dx - widthSizeAction / 3 < 20
                ? 20
                : pointerPosition.dx - widthSizeAction / 3,
            child: Transform.scale(
                scale: animationValue,
                alignment: Alignment.topLeft,
                child: _buildActions(hide)),
          );
        }
      },
      child: widget.child,
    );
  }

  Widget get _space => const Gap(8);

  Widget _buildActions(hide) {
    return ValueListenableBuilder(
      valueListenable: isHover,
      builder: (context, value, child) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: !isHover.value ? const SizedBox() : child!,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _space,
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: appColors.appBackground,
                borderRadius: borderRadius,
                boxShadow: appBoxShadow,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: chatEmojiRectionAssets
                        .mapIndexed<Widget>((index, e) =>
                            WidgetAnimationStaggeredItem(
                              duration: const Duration(milliseconds: 250),
                              index: index,
                              type: AnimationStaggeredType.bottomToTop,
                              child: WidgetInkWellTransparent(
                                onTap: () {
                                  hide();
                                  chatDetailBloc.add(
                                      ChatDetailSendReactionMessagesEvent(
                                          widget.data, index));
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: WidgetAppLottie(
                                      assetlottie('emoji/$e'),
                                      package: '_iwu_pack_chat_firestore',
                                      width: 28,
                                      height: 28),
                                ),
                              ),
                            ))
                        .toList()),
              ),
            ),
            _space,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: appColors.appBackground,
                borderRadius: borderRadius,
                boxShadow: appBoxShadow,
              ),
              child: Row(
                children: [
                  WidgetAnimationStaggeredItem(
                    duration: const Duration(milliseconds: 250),
                    index: 0,
                    type: AnimationStaggeredType.bottomToTop,
                    child: WidgetInkWellTransparent(
                      onTap: () {
                        hide();
                        chatDetailBloc
                            .add(ChatDetailReplyMessagesEvent(widget.data));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: WidgetAppSVG(
                          assetsvg('reply'),
                          package: '_iwu_pack_chat_firestore',
                          width: 24,
                        ),
                      ),
                    ).opacity(isEnableReply ? 1 : .6).ignore(!isEnableReply),
                  ),
                  WidgetAnimationStaggeredItem(
                    duration: const Duration(milliseconds: 250),
                    index: 1,
                    type: AnimationStaggeredType.bottomToTop,
                    child: WidgetInkWellTransparent(
                      onTap: () {
                        hide();
                        chatDetailBloc
                            .add(ChatDetailEditMessagesEvent(widget.data));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: WidgetAppSVG(
                          assetsvg('edit'),
                          package: '_iwu_pack_chat_firestore',
                          width: 24,
                        ),
                      ),
                    )
                        .opacity(isEnableCopyEdit ? 1 : .6)
                        .ignore(!isEnableCopyEdit),
                  ),
                  WidgetAnimationStaggeredItem(
                    duration: const Duration(milliseconds: 250),
                    index: 2,
                    type: AnimationStaggeredType.bottomToTop,
                    child: widget.wrapCopyBuilder != null
                        ? widget.wrapCopyBuilder!(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: WidgetAppSVG(
                                assetsvg('copy'),
                                package: '_iwu_pack_chat_firestore',
                                width: 24,
                              ),
                            ),
                            onTap: () async {
                              chatDetailBloc.add(ChatDetailCopyMessageEvent(
                                  widget.data[kDbCONTENT]));
                              await Future.delayed(const Duration(seconds: 1));
                              hide();
                            },
                          )
                            .opacity(isEnableCopyEdit ? 1 : .6)
                            .ignore(!isEnableCopyEdit)
                        : WidgetInkWellTransparent(
                            onTap: () {
                              hide();
                              chatDetailBloc.add(ChatDetailCopyMessageEvent(
                                  widget.data[kDbCONTENT]));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: WidgetAppSVG(
                                assetsvg('copy'),
                                package: '_iwu_pack_chat_firestore',
                                width: 24,
                              ),
                            ),
                          )
                            .opacity(isEnableCopyEdit ? 1 : .6)
                            .ignore(!isEnableCopyEdit),
                  ),
                  WidgetAnimationStaggeredItem(
                    duration: const Duration(milliseconds: 250),
                    index: 3,
                    type: AnimationStaggeredType.bottomToTop,
                    child: WidgetInkWellTransparent(
                      onTap: () {
                        hide();
                        chatDetailBloc.add(ChatDeleteMessagesEvent(timestamp));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: WidgetAppSVG(
                          assetsvg('delete'),
                          package: '_iwu_pack_chat_firestore',
                          width: 24,
                        ),
                      ),
                    ).opacity(isEnableDelete ? 1 : .6).ignore(!isEnableDelete),
                  ),
                  if (isImage) ...[
                    Container(
                      height: 16,
                      width: .8,
                      color: appColors.text.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    WidgetInkWellTransparent(
                      onTap: () {
                        hide();
                        chatOptions.downloadFromUrl?.call(
                            widget.data[kDbCONTENTURL],
                            name: widget.data[kDbCONTENTFILEINFOS]
                                ?[kDbFILEFILENAME]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: WidgetAppSVG(
                          assetsvg('download'),
                          package: '_iwu_pack_chat_firestore',
                          width: 24,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            _space,
          ],
        ),
      ),
    );
  }
}

get appBoxShadow => [
      BoxShadow(
        color: appColors.text.withOpacity(0.06),
        blurRadius: 4,
        spreadRadius: 0,
      )
    ];
