import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import '../bloc/chat_list_bloc.dart';

class WidgetUserChatListBuilder extends StatelessWidget {
  final Widget Function(String fullname, String? thumbnal) builder;
  final String id;
  const WidgetUserChatListBuilder({
    Key? key,
    required this.id,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      bloc: chatListBloc,
      builder: (_, state) {
        String? fullname() {
          Map? user = state.getUserByKeys(id);
          return chatGetFullNameUser(user);
        }

        String? thumbnail() {
          Map? user = state.getUserByKeys(id);
          return chatGetThumbnailUser(user);
        }

        return builder(fullname() ?? "", thumbnail());
      },
    );
  }
}
