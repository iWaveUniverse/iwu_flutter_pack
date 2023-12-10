part of 'chat_detail_bloc.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object> get props => [];
}

class ChatDetailInitialEvent extends ChatDetailEvent {
  final TickerProvider? tickerProvider;
  final VoidCallback? callback;
  final Function(StreamSubscription) messagesSubscription;
  final Function(StreamSubscription) conversationSubscription;

  const ChatDetailInitialEvent({
    required this.tickerProvider,
    required this.messagesSubscription,
    required this.conversationSubscription,
    this.callback,
  });
}

class ChatSendMessageEvent extends ChatDetailEvent {
  final MessageType type;
  final String text;
  final File? image;

  final Uint8List? imageData;
  final String? imageExt;
  final String? imageFileName;
  final String? imageFileMime;
  final int? assetFileDuration;

  final Map? customData;

  final bool? isEnableNotif;
  final String? bodyNotif;

  const ChatSendMessageEvent({
    required this.type,
    this.imageData,
    this.text = '',
    this.image,
    this.imageExt,
    this.imageFileMime,
    this.imageFileName,
    this.assetFileDuration,
    this.customData,
    this.isEnableNotif,
    this.bodyNotif,
  });
}

class ChatDetailLoadMoreMessagesEvent extends ChatDetailEvent {}

class ChatUpdateMessagesEvent extends ChatDetailEvent {}

class ChatDeleteMessagesEvent extends ChatDetailEvent {
  final int timestamp;
  const ChatDeleteMessagesEvent(this.timestamp);
}

class ChatDetailDisposeEvent extends ChatDetailEvent {}

class ChatDetailReplyMessagesEvent extends ChatDetailEvent {
  final Map<String, dynamic> repllyDoc;
  const ChatDetailReplyMessagesEvent(this.repllyDoc);
}

class ChatDetailEditMessagesEvent extends ChatDetailEvent {
  final Map<String, dynamic> editDoc;
  const ChatDetailEditMessagesEvent(this.editDoc);
}

class ChatDetailEditLastMessagesEvent extends ChatDetailEvent {}

class ChatDetailResetEditOrReplyEvent extends ChatDetailEvent {}

class ChatDetailShowMessageActionsEvent extends ChatDetailEvent {
  final Map<String, dynamic>? messageActionDoc;
  const ChatDetailShowMessageActionsEvent(this.messageActionDoc);
}

class ChatDetailResetShowMessageActionsEvent extends ChatDetailEvent {}

class ChatDetailSendReactionMessagesEvent extends ChatDetailEvent {
  final Map<String, dynamic> doc;
  final int value;
  const ChatDetailSendReactionMessagesEvent(this.doc, this.value);
}

class ChatDetailUnsendReactionMessagesEvent extends ChatDetailEvent {
  final Map<String, dynamic> doc;
  const ChatDetailUnsendReactionMessagesEvent(this.doc);
}

class ChatDetailCopyMessageEvent extends ChatDetailEvent {
  final String text;

  const ChatDetailCopyMessageEvent(this.text);
}

class ChatDetailPastTextInputEvent extends ChatDetailEvent {
  final String? text;

  const ChatDetailPastTextInputEvent(this.text);
}
