import 'package:_iwu_pack_chat_firestore/options.dart';
import 'package:_private_core/_private_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:_iwu_pack_chat_firestore/chat_list/widget/widget_user_builder.dart';
import 'package:_iwu_pack_chat_firestore/connection_status/widgets/widget_user_received_builder.dart';
import 'package:_private_core/widgets/widgets.dart';

class WidgetMessageState extends StatelessWidget {
  final dynamic seen;
  final List<String> seenUsers;
  final bool isMe;
  final dynamic timestamp;
  final dynamic delivered;
  final String? firebaseId;
  const WidgetMessageState({
    Key? key,
    required this.seenUsers,
    required this.seen,
    required this.isMe,
    required this.timestamp,
    this.firebaseId,
    this.delivered,
  }) : super(key: key);

  String _humanReadableTime() => DateFormat('HH:mm')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = chatOptions.chatTextStyleMessageState;
    Color color = chatOptions.chatIconColorMessageState ?? textStyle.color!;
    Widget buildSent() {
      if (firebaseId != null) {
        return WidgetUserReceivedStatusBuilder(
          id: firebaseId!,
          builder: (received) {
            if (received >= timestamp) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done,
                    color: color,
                    size: 12.0,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '${appTranslateText('received')} ${_humanReadableTime()}',
                    style: textStyle,
                  ),
                ],
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.done,
                  color: color,
                  size: 12.0,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  '${appTranslateText('sent')} ${_humanReadableTime()}',
                  style: textStyle,
                ),
              ],
            );
          },
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.done,
            color: color,
            size: 12.0,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            '${appTranslateText('sent')} ${_humanReadableTime()}',
            style: textStyle,
          ),
        ],
      );
    }

    Widget seenWidget = const SizedBox();
    if (!isMe) {
      seenWidget = Text(
        _humanReadableTime(),
        style: textStyle,
      );
    } else if (seen) {
      seenWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chatOptions.chatEnableAvatarMessageState)
            ...seenUsers.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: WidgetUserChatListBuilder(
                    id: e,
                    builder: (fullname, thumbnail) {
                      return WidgetAvatar.withoutBorder(
                        radius: 6.5,
                        imageUrl: thumbnail,
                      );
                    }),
              ),
            ),
          Icon(
            Icons.done_all,
            color: color,
            size: 12.0,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            '${appTranslateText('read')} ${_humanReadableTime()}',
            style: textStyle,
          ),
        ],
      );
    } else if (delivered is Future) {
      seenWidget = FutureBuilder(
          future: delivered,
          builder: (context, res) {
            switch (res.connectionState) {
              case ConnectionState.done:
                return buildSent();
              default:
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: color,
                      size: 12.0,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      '${appTranslateText('sending')} ${_humanReadableTime()}',
                      style: textStyle,
                    ),
                  ],
                );
            }
          });
    } else {
      seenWidget = buildSent();
    }
    return seenWidget;
  }
}
