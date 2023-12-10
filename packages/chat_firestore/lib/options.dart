import 'package:_private_core/_private_core.dart';
import 'package:_private_core/theme/option_chat.dart';
import 'package:flutter/material.dart';

import '_iwu_pack_chat_firestore.dart';

PChatOptionsImpl get chatOptions =>
    coreConfig.coreThemes.chatOptions as PChatOptionsImpl;

class PChatOptionsImpl extends PChatOptions {
  Function(TickerProvider)? chatOnInitDetail;
  Function()? chatOnDisposeDetail;

  //UI chat detail screen
  Widget Function(Widget child, bool isLoadingList, bool isLoadingDetail)?
      chatDetailBackgroundBuilder;
  Widget Function(ChatDetailState state, bool isBot) chatDetailProfileBuilder;
  Widget Function(ChatDetailState state, TextEditingController controller,
      FocusNode node, Function() onSend, bool isBot) chatDetailInputBuilder;

  Widget Function(Widget child, bool isMe) chatMessagePositionBuilder;

  //Message state styles
  bool chatEnableAvatarMessageState;
  TextStyle chatTextStyleMessageState;
  Color? chatIconColorMessageState;

  //Message content styles
  List<Widget> Function(List messages)? chatDetailGroupedMessagesBuilder;
  Widget Function(Widget child, dynamic data, dynamic timestamp)
      chatDetailContentActionBuilder;
  Widget Function(Map data, dynamic indexOfGroup, [String? text])
      chatMessageContentBuilder;

  //Owner infos and messages display
  Widget Function(Widget seenState, String? thumbnail, String fullname,
      List<Widget> messages, bool isMe)? chatOwnerBubbleBuilder;

  //Reaction icon display builder
  Widget Function(
          Widget child, Map reactions, Map<String, dynamic> data, bool isMe)
      chatReactionWrapBuilder;

  Future Function(String url, {String? name})? downloadFromUrl;

  PChatOptionsImpl({
    this.chatOnInitDetail,
    this.chatOnDisposeDetail,
    this.chatDetailBackgroundBuilder,
    required this.chatDetailProfileBuilder,
    required this.chatDetailInputBuilder,
    required this.chatTextStyleMessageState,
    this.chatEnableAvatarMessageState = true,
    this.chatIconColorMessageState,
    this.chatDetailGroupedMessagesBuilder,
    required this.chatDetailContentActionBuilder,
    required this.chatMessageContentBuilder,
    required this.chatMessagePositionBuilder,
    required this.chatOwnerBubbleBuilder,
    required this.chatReactionWrapBuilder,
    this.downloadFromUrl,
  });
}
