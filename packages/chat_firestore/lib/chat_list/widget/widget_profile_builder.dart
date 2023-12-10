import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_iwu_pack_chat_firestore/_iwu_pack_chat_firestore.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';

class WidgetProfileChatListBuilder extends StatelessWidget { 
  final Widget Function(String fullname, String? thumbnal, Map conversationData)
      builder;
  final ChatConversationType conversationType;
  //Id of user or conversation
  final String id;
  const WidgetProfileChatListBuilder({
    Key? key,
    required this.conversationType,
    required this.id,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      bloc: chatListBloc,
      builder: (_, state) {
        String? fullname() {
          if (conversationType == ChatConversationType.solo) {
            Map? user = state.getUserByKeys(id);
            return chatGetFullNameUser(user);
          } else {
            if (state.conversations.any((e) => e.conversationId == id)) {
              return state.conversations
                      .firstWhere((e) => e.conversationId == id)
                      .data[kDbGROUPNAME] ??
                  '';
            } else {
              return '';
            }
          }
        }

        String? thumbnail() {
          if (conversationType == ChatConversationType.solo) {
            Map? user = state.getUserByKeys(id);
            return chatGetThumbnailUser(user);
          } else {
            if (state.conversations.any((e) => e.conversationId == id)) {
              return state.conversations
                      .firstWhere((e) => e.conversationId == id)
                      .data[kDbTHUMBNAIL] ??
                  '';
            } else {
              return '';
            }
          }
        }

        return builder(
            fullname() ?? "",
            thumbnail(),
            state.conversations.any((e) => e.conversationId == id)
                ? state.conversations
                    .firstWhere((e) => e.conversationId == id)
                    .data
                : {});
      },
    );
  }
}
