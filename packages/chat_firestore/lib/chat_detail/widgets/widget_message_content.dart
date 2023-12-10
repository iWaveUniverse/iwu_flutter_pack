import 'dart:io';

import 'package:_iwu_pack_chat_firestore/options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:_iwu_pack_chat_firestore/chat_detail/bloc/chat_detail_bloc.dart';
import 'package:_iwu_pack_chat_firestore/chat_detail/chat_helper.dart';
import 'package:_iwu_pack_chat_firestore/chat_list/widget/widget_user_builder.dart';
import 'package:_iwu_pack_chat_firestore/utils/utils.dart';
import 'package:_private_core/_private_core.dart';
import 'package:_private_core/widgets/widgets.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';

import '../message.dart';
import 'widget_message_state.dart';

bool get isBot => chatDetailBloc.params.isBot;

bool get isMobile => !kIsWeb && !Platform.isMacOS && !Platform.isWindows;

class WidgetMessageOwner extends StatelessWidget {
  final Map<String, dynamic> data;
  final String peerId;
  final String toPeerId;
  final dynamic delivered;
  final List<Message> messages;
  const WidgetMessageOwner({
    Key? key,
    required this.messages,
    required this.data,
    required this.peerId,
    required this.toPeerId,
    required this.delivered,
  }) : super(key: key);

  bool get isMe => getIsMe(data);

  int get timestamp => data[kDbTIMESTAMP];

  MessageIndexOfGroup indexOfGroup(List<Message> messages, item) {
    if (messages.length == 1) return MessageIndexOfGroup.none;
    if (messages.indexOf(item) == 0) return MessageIndexOfGroup.top;
    if (messages.indexOf(item) == messages.length - 1) {
      return MessageIndexOfGroup.bottom;
    }
    return MessageIndexOfGroup.center;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> seens =
        MessageStateProvider.seenStateOf(context).value;
    bool seen = false;
    List<String> seenUsers = [];
    seens.forEach((key, value) {
      if (key != loggedFirebaseId) {
        seen = value >= timestamp;
        if (value >= timestamp) seenUsers.add(key);
      }
    });
    if (isBot) {
      return chatOptions.chatOwnerBubbleBuilder!(
          _buildState(seen, seenUsers),
          isMe ? appPrefs.loginUser!.thumbnail : chatOptions.botThumbnail,
          isMe ? appTranslateText('you') : chatOptions.botLabel ?? "",
          messages.map((e) => _buildMessageChild(e)).toList(),
          isMe);
    }
    return WidgetUserChatListBuilder(
        id: peerId,
        builder: (fullname, thumbnail) {
          if (chatOptions.chatOwnerBubbleBuilder != null) {
            return chatOptions.chatOwnerBubbleBuilder!(
                _buildState(seen, seenUsers),
                isMe ? appPrefs.loginUser!.thumbnail : thumbnail,
                isMe ? appTranslateText('you') : fullname,
                messages.map((e) => _buildMessageChild(e)).toList(),
                isMe);
          }
          if (isMobile) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isMe
                    ? [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Spacer(),
                                      _buildState(seen, seenUsers),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        appTranslateText('you'),
                                        style: w500TextStyle().copyWith(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...messages
                                    .map((e) => _buildMessageChild(e))
                                    .toList()
                              ],
                            ),
                          ),
                        ),
                        WidgetAvatar.withoutBorder(
                          radius: 20,
                          imageUrl:
                              isMe ? appPrefs.loginUser!.thumbnail : thumbnail,
                        )
                      ]
                    : [
                        WidgetAvatar.withoutBorder(
                          radius: 20,
                          imageUrl:
                              isMe ? appPrefs.loginUser!.thumbnail : thumbnail,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        fullname,
                                        style: w500TextStyle().copyWith(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      _buildState(seen, seenUsers),
                                    ],
                                  ),
                                ),
                                ...messages
                                    .map((e) => _buildMessageChild(e))
                                    .toList()
                              ],
                            ),
                          ),
                        ),
                      ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetAvatar.withoutBorder(
                  radius: 20,
                  imageUrl: isMe ? appPrefs.loginUser!.thumbnail : thumbnail,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isMe ? appTranslateText('you') : fullname,
                              style: w500TextStyle().copyWith(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            _buildState(seen, seenUsers),
                          ],
                        ),
                      ),
                      ...messages.map((e) => _buildMessageChild(e)).toList()
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildState(seen, seenUsers) {
    return WidgetMessageState(
      seen: seen,
      seenUsers: seenUsers,
      delivered: delivered,
      timestamp: timestamp,
      isMe: isMe,
      firebaseId: toPeerId,
    );
  }

  Widget _buildMessageChild(Message e) {
    return Message.wrapMessage(
      animationController: e.animationController,
      child: WidgetMessageContent(
        delivered: ChatHelper.getMessageStatus(peerId, e.timestamp),
        key: ValueKey('${e.timestamp}-Message.wrapMessage'),
        data: e.data,
        indexOfGroup: indexOfGroup(messages, e),
      ),
    );
  }
}

class WidgetMessageContent extends StatefulWidget {
  final MessageIndexOfGroup indexOfGroup;
  final Map<String, dynamic> data;
  final dynamic delivered;
  const WidgetMessageContent({
    Key? key,
    required this.indexOfGroup,
    required this.data,
    required this.delivered,
  }) : super(key: key);

  @override
  _WidgetMessageContentState createState() => _WidgetMessageContentState();
}

class _WidgetMessageContentState extends State<WidgetMessageContent> {
  late Map<String, dynamic> data = widget.data;

  int get timestamp => data[kDbTIMESTAMP];

  String get content => isBot || chatDetailBloc.conversationData == null
      ? data[kDbCONTENT]
      : ChatHelper.decrypt(
          chatDetailBloc.conversationData![kDbENCRYPTKEY], data[kDbCONTENT]);

  bool get isMe => getIsMe(data);

  bool hasReactions(context) {
    Map<dynamic, dynamic> reactions =
        MessageStateProvider.reactionStateOf(context).value;
    return reactions.containsKey('$timestamp') &&
        reactions['$timestamp'] != null;
  }

  dynamic reactions(context) {
    Map<dynamic, dynamic> reactions =
        MessageStateProvider.reactionStateOf(context).value;
    return reactions['$timestamp'] ?? <dynamic, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (MessageType.values[data[kDbMESSAGETYPE]]) {
      case MessageType.audio:
      case MessageType.image:
      case MessageType.gif:
      case MessageType.lottie:
        child = chatOptions.chatMessageContentBuilder(
            data, widget.indexOfGroup, content);
        break;
      default:
        child = ValueListenableBuilder<Map>(
          valueListenable: chatDetailBloc.messageUpdatedValue,
          builder: (_, value, child) {
            if (value.containsKey('$timestamp') &&
                value['$timestamp'] != null) {
              return chatOptions.chatMessageContentBuilder(
                  data, widget.indexOfGroup, value['$timestamp'] ?? "");
            }
            return child!;
          },
          child: chatOptions.chatMessageContentBuilder(
              data, widget.indexOfGroup, content),
        );
        break;
    }

    if (hasReactions(context)) {
      child = chatOptions.chatReactionWrapBuilder(
          child, reactions(context), data, isMe);
    }

    return chatOptions.chatMessagePositionBuilder(
        chatOptions.chatDetailContentActionBuilder(child, data, timestamp),
        isMe);
  }
}

List<String> chatEmojiRectionAssets = [
  'Angry Face',
  'Astonished Face',
  'Disappointed Face',
  'Loudly Crying Face',
  'Rolling on the Floor Laughing',
  'Smiling Face with Heart-Eyes',
  'Thumbs Down',
  'Thumbs Up',
];

List<String> chatEmojiAssets = [
  "Face with Monocle",
  "Angry Face",
  "Anxious Face with Sweat",
  "Astonished Face",
  "Backhand Index Pointing Down",
  "Backhand Index Pointing Right",
  "Backhand Index Pointing Up",
  "Beaming Face with Smiling Eyes",
  "Beating Heart",
  "Broken Heart",
  "Call Me Hand",
  "Clapping Hands",
  "Cold Face",
  "Confounded Face",
  "Confused Face",
  "Disappointed Face",
  "Dizzy Face",
  "Dizzy",
  "Drooling Face",
  "Exploding Head",
  "Expressionless Face",
  "Eyes",
  "Face Blowing a Kiss",
  "Face Savoring Food",
  "Face Screaming in Fear",
  "Face Vomiting",
  "Face with Hand Over Mouth",
  "Face with Head-Bandage",
  "Face with Medical Mask",
  "Face with Raised Eyebrow",
  "Face with Rolling Eyes",
  "Hugging Face",
  "Loudly Crying Face",
  "Rolling on the Floor Laughing",
  "Smiling Face with Heart-Eyes",
  "Thumbs Down",
  "Thumbs Up",
];
