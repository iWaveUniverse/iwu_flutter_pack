import 'dart:async';

import 'package:_iwu_pack_chat_firestore/chat_detail/message.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';
import 'package:_iwu_pack_chat_firestore/firestore_resouce/instances.dart';
import 'package:_iwu_pack_chat_firestore/utils/utils.dart';
import 'package:_private_core/_private_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat_detail_asset.dart';

part 'chat_detail_asset_event.dart';
part 'chat_detail_asset_state.dart';

ChatDetailAssetBloc get chatDetailAssetBloc =>
    appFindInstance<ChatDetailAssetBloc>();

class ChatDetailAssetBloc
    extends Bloc<ChatDetailAssetEvent, ChatDetailAssetState> {
  StreamSubscription? _subscription;

  DocumentReference<Map<String, dynamic>> get _docRef =>
      colCONVERSATIONS.doc(state.conversationData?[kDbCONVERSATIONID]);

  CollectionReference<Map<String, dynamic>> get _colRef =>
      _docRef.collection(kCollectionMESSAGES);

  ChatDetailAssetBloc() : super(ChatDetailAssetState(images: [])) {
    on<InitChatDetailAssetEvent>(_init);
    on<UpdateChatDetailAssetEvent>(_update);
    on<DisposeChatDetailAssetEvent>(_dispose);
  }

  _init(event, emit) async {
    state.conversationData = event.conversationData;
    if (!isLoggedFirebaseAuth()) return;
    QuerySnapshot query = await _colRef
        .orderBy(kDbTIMESTAMP)
        .where(kDbMESSAGETYPE, isEqualTo: MessageType.image.index)
        .get();

    add(UpdateChatDetailAssetEvent(query.docs.map((e) {
      return ChatDetailAsset(
          data: e.data() as Map, timestamp: (e.data() as Map)[kDbTIMESTAMP]);
    }).toList()));

    _subscription = _colRef
        .orderBy(kDbTIMESTAMP)
        .where(kDbMESSAGETYPE, isEqualTo: MessageType.image.index)
        .snapshots()
        .listen((query) {
      add(UpdateChatDetailAssetEvent(query.docs.map((e) {
        return ChatDetailAsset(
            data: e.data(), timestamp: (e.data())[kDbTIMESTAMP]);
      }).toList()));
    });
  }

  _update(event, emit) {
    emit(state.update(images: event.images));
  }

  _dispose(event, emit) {
    _subscription?.cancel();
  }
}
