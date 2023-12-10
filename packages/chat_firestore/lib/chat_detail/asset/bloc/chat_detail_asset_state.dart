part of 'chat_detail_asset_bloc.dart';

class ChatDetailAssetState {
  bool isLoading;
  Map? conversationData;

  List<ChatDetailAsset> images;

  ChatDetailAssetState({
    this.isLoading = true,
    this.conversationData,
    required this.images,
  });

  ChatDetailAssetState update({
    bool? isLoading,
    Map? conversationData,
    List<ChatDetailAsset>? images,
  }) {
    return ChatDetailAssetState(
      isLoading: isLoading ?? this.isLoading,
      conversationData: conversationData ?? this.conversationData,
      images: images ?? this.images,
    );
  }
}
