part of 'chat_list_bloc.dart';

abstract class ChatListEvent {}

class ChatListInitEvent extends ChatListEvent {
  // This field only call in disable event to cancel process in init event
  final bool isJustForReset;
  final bool isLoadingInitialize;
  final bool Function(Map)? conditionInitialize;

  ChatListInitEvent( {
    this.isJustForReset = false,
    this.conditionInitialize,
    this.isLoadingInitialize = true,
  });
}

class LoadUserInfoConversationEvent extends ChatListEvent {
  final List firebaseIds;

  LoadUserInfoConversationEvent(this.firebaseIds);
}

class ChatUpdateListConversationEvent extends ChatListEvent {
  final List<ChatListConversation> conversations;

  ChatUpdateListConversationEvent(this.conversations);
}

class ChatListRemoveEvent extends ChatListEvent {
  final String conversationId;

  ChatListRemoveEvent(this.conversationId);
}

class ChatListReadItemEvent extends ChatListEvent {
  BuildContext context;

  ChatListConversation? c;

  String? firebaseId;
  String? displayName;
  String? thumbnail;

  ChatListReadItemEvent(
    this.context, {
    this.c,
    this.firebaseId,
    this.displayName,
    this.thumbnail,
  });
}

class ChatListDisposeEvent extends ChatListEvent {}
