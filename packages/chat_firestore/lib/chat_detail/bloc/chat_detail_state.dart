part of 'chat_detail_bloc.dart';

class ChatDetailState {
  bool isLoading;
  List<Message> messages;

  //Edit
  bool isEditKeyboard = false;
  Map<String, dynamic>? editDoc;

  //Reply
  bool isReplyKeyboard = false;
  Map<String, dynamic>? replyDoc;

  //Message action
  bool isShowMessageActions = false;
  Map<String, dynamic>? messageActionDoc;

  ChatMessageDefault? defaultMessage;
  PlatformStatusChat? statusChat;

  ChatDetailState({
    this.isLoading = true,
    required this.messages,
    this.editDoc,
    this.isEditKeyboard = false,
    this.isReplyKeyboard = false,
    this.replyDoc,
    this.isShowMessageActions = false,
    this.messageActionDoc,
    this.defaultMessage,
    this.statusChat,
  });

  ChatDetailState update({
    bool? isLoading,
    List<Message>? messages,
    bool? needScroll,
    bool? isEditKeyboard,
    Map<String, dynamic>? editDoc,
    bool? isReplyKeyboard,
    Map<String, dynamic>? replyDoc,
    bool? isShowMessageActions,
    Map<String, dynamic>? messageActionDoc,
    ChatMessageDefault? defaultMessage,
    PlatformStatusChat? statusChat,
  }) {
    return ChatDetailState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      isEditKeyboard: isEditKeyboard ?? this.isEditKeyboard,
      editDoc: editDoc ?? this.editDoc,
      isReplyKeyboard: isReplyKeyboard ?? this.isReplyKeyboard,
      replyDoc: replyDoc ?? this.replyDoc,
      messageActionDoc: messageActionDoc ?? this.messageActionDoc,
      isShowMessageActions: isShowMessageActions ?? this.isShowMessageActions,
      defaultMessage: defaultMessage ?? this.defaultMessage,
      statusChat: statusChat ?? this.statusChat,
    );
  }
}
