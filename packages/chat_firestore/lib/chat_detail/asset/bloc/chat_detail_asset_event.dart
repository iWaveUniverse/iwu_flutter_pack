part of 'chat_detail_asset_bloc.dart';
 
abstract class ChatDetailAssetEvent {}

class InitChatDetailAssetEvent extends ChatDetailAssetEvent {
  Map? conversationData;
  InitChatDetailAssetEvent(this.conversationData);
}

class UpdateChatDetailAssetEvent extends ChatDetailAssetEvent {
  List<ChatDetailAsset>? images;
  UpdateChatDetailAssetEvent(this.images);
}

class DisposeChatDetailAssetEvent extends ChatDetailAssetEvent {}
