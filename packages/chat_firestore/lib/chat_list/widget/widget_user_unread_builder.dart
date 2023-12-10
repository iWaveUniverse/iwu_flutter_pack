import 'package:_iwu_pack_chat_firestore/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_list_bloc.dart';

class WidgetUserUnreadChatListBuilder extends StatelessWidget {
  final Widget Function(int unread) builder;
  final String id;
  const WidgetUserUnreadChatListBuilder({
    Key? key,
    required this.id,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      bloc: chatListBloc,
      builder: (_, state) {
        int unread = 0;
        if (state.conversations.any((e) =>
            e.userIds.map((e) => e[kDbFIREBASEID]).toList().contains(id))) {
          unread = state.conversations
              .firstWhere((e) =>
                  e.userIds.map((e) => e[kDbFIREBASEID]).toList().contains(id))
              .unread;
        }
        return builder(unread);
      },
    );
  }
}
