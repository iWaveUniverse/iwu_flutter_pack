part of 'chat_list_bloc.dart';

class ChatListState {
  final bool isLoadingInitialize;
  final bool isLoading;
  final List<ChatListConversation> conversations;
  final Map usersByKeys;

  getUserByKeys(key) {
    return usersByKeys[key] ?? kDefaultUserInfo(key);
  }

  int get unread {
    int total = 0;
    for (var e in conversations) {
      total += e.unread;
    }
    return total;
  }

  ChatListState({
    required this.conversations,
    required this.usersByKeys,
    this.isLoadingInitialize = true,
    this.isLoading = true,
  });

  ChatListState update({
    bool? isLoadingInitialize,
    bool? isLoading,
    List<ChatListConversation>? conversations,
    Map? usersByKeys,
  }) {
    return ChatListState(
      usersByKeys: usersByKeys ?? this.usersByKeys,
      isLoadingInitialize: isLoadingInitialize ?? this.isLoadingInitialize,
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
    );
  }
}
