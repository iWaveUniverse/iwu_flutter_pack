import 'dart:async';
import 'package:_iwu_pack_chat_firestore/firestore_resouce/instances.dart';
import 'package:_iwu_pack_chat_firestore/options.dart';
import 'package:_private_core/_private_core.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_iwu_pack_chat_firestore/chat_detail/chat_detail_screen.dart';
import 'package:_iwu_pack_chat_firestore/chat_detail/chat_helper.dart';
import 'package:_iwu_pack_chat_firestore/utils/utils.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';

import '../../connection_status/bloc/connection_status_bloc.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

String? chatGetFullNameUser(data) => data?['displayName'];

String? chatGetThumbnailUser(data) => data?['thumbnail'];

String? chatGetFirebaseIdUser(data) => data?['firebaseId'];

ChatListBloc get chatListBloc => appFindInstance<ChatListBloc>();

class ChatListConversation {
  int timestamp;
  ChatConversationType conversationType;
  String conversationId;
  Map data = {};
  List userIds = [];
  int unread;
  Map<String, dynamic> lastMessage = {};
  bool isEmptyMessages;

  ChatListConversation({
    this.timestamp = 0,
    this.conversationId = '',
    this.conversationType = ChatConversationType.solo,
    this.unread = 0,
    this.isEmptyMessages = false,
  });

  @override
  String toString() {
    return 'ChatListConversation={timestamp: $timestamp,conversationId: $conversationId,conversationType: $conversationType,unread: $unread,isEmptyMessages: $isEmptyMessages}';
  }
}

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  StreamSubscription? _converstationsSubscription;
  final List<StreamSubscription> _msgsSubscription = [];

  ChatListBloc() : super(ChatListState(conversations: [], usersByKeys: {})) {
    on<ChatListInitEvent>(
      _onInitial,
      transformer: restartable(),
    );
    on<ChatListReadItemEvent>(_onReadItemEvent);
    on<ChatListDisposeEvent>(_onDisposeEvent);
    on<ChatListRemoveEvent>(onRemoveEvent);
    on<ChatUpdateListConversationEvent>(_onUpdateConversation);
    on<LoadUserInfoConversationEvent>(_onLoadUserInfo);
  }

  _onUpdateConversation(
      ChatUpdateListConversationEvent event, Emitter<ChatListState> emit) {
    emit(state.update(conversations: event.conversations));
  }

  onRemoveEvent(ChatListRemoveEvent event, Emitter<ChatListState> emit) {
    ChatHelper.removeConversation(event.conversationId);
    state.conversations
        .removeWhere((e) => e.conversationId == event.conversationId);
    emit(state.update());
  }

  _onReadItemEvent(ChatListReadItemEvent event, Emitter<ChatListState> emit) {
    if (event.c != null) {
      if (event.c!.conversationType == ChatConversationType.solo) {
        String firebaseId = event.c!.userIds.first[kDbFIREBASEID];
        Map? user = state.getUserByKeys(firebaseId);
        String? fullname = chatGetFullNameUser(user);
        String? thumbnail = chatGetThumbnailUser(user);
        appPushNamed(event.context, ChatDetailScreen.route,
            arguments: ChatDetailParams.solo(
              soloFirebaseId: firebaseId,
              name: fullname,
              thumbnail: thumbnail,
            ));
      } else {
        appPushNamed(
          event.context,
          ChatDetailScreen.route,
          arguments: ChatDetailParams.group(
            conversationId: event.c!.conversationId,
            name: event.c!.data[kDbGROUPNAME],
            thumbnail: event.c!.data[kDbTHUMBNAIL],
          ),
        );
      }
    } else if (event.firebaseId != null) {
      appPushNamed(
        event.context,
        ChatDetailScreen.route,
        arguments: ChatDetailParams.solo(
          soloFirebaseId: event.firebaseId,
          name: event.displayName,
          thumbnail: event.thumbnail,
        ),
      );
    }
  }

  _onDisposeEvent(event, Emitter<ChatListState> emit) {
    add(ChatListInitEvent(isJustForReset: true));
    _converstationsSubscription?.cancel();
    for (var e in _msgsSubscription) {
      e.cancel();
    }
    _msgsSubscription.clear();
    chatConnectionStatusBloc.add(ConnectionStatusDisposeEvent());
  }

  _onLoadUserInfo(
      LoadUserInfoConversationEvent event, Emitter<ChatListState> emit) async {
    if (!isLoggedFirebaseAuth()) return;
    var usersByKeys = state.usersByKeys;

    for (var firebaseId in event.firebaseIds) {
      if (firebaseId != null) {
        Map<String, dynamic>? data = await getUserInfoFromFirestore(firebaseId);
        usersByKeys[firebaseId] = data;
      }
    }

    emit(state.update(
      usersByKeys: usersByKeys,
    ));
  }

  _onInitial(ChatListInitEvent event, Emitter<ChatListState> emit) async {
    if (!isLoggedFirebaseAuth() || event.isJustForReset) return;
    bool showConverstaion(docData) {
      List users = docData[kDbMEMBERSDETAIL]
          .where((e) => e[kDbFIREBASEID] != loggedFirebaseId)
          .toList();
      return (event.conditionInitialize?.call(docData) ?? true) &&
          users.isNotEmpty &&
          !users.any((e) => e == null);
    }

    try {
      emit(state.update(
          isLoading: true, isLoadingInitialize: event.isLoadingInitialize));
      QuerySnapshot q = await colCONVERSATIONS
          .where(kDbMEMBERSFIREBASEID, arrayContains: loggedFirebaseId)
          .orderBy(kDbLASTMESSAGETIME, descending: true)
          .get();
      List requestUsers = [];
      List<ChatListConversation> cons = [];

      for (var e in _msgsSubscription) {
        e.cancel();
      }
      _msgsSubscription.clear();
      for (var d in q.docs) {
        Map docData = d.data() as Map;
        if (showConverstaion(docData)) {
          int timestamp = docData[kDbMEMBERSDETAIL]
                  .any((e) => e[kDbFIREBASEID] == loggedFirebaseId)
              ? docData[kDbMEMBERSDETAIL].firstWhere((e) =>
                      e[kDbFIREBASEID] == loggedFirebaseId)[kDbTIMESTAMP] ??
                  0
              : 0;
          ChatListConversation conversation = ChatListConversation()
            ..conversationId = d.id
            ..userIds = docData[kDbMEMBERSDETAIL]
                .where((e) => e[kDbFIREBASEID] != loggedFirebaseId)
                .toList()
            ..conversationType =
                ChatConversationType.values.byName(docData[kDbCONVERSATIONTYPE])
            ..data = docData;
          requestUsers.addAll(docData[kDbMEMBERSDETAIL].toList());

          if (docData[kDbLASTMESSAGETIME] != null &&
              docData[kDbLASTMESSAGETIME] != 0) {
            conversation.timestamp = docData[kDbLASTMESSAGETIME];
            conversation.unread = (await colCONVERSATIONS
                    .doc(d.id)
                    .collection(kCollectionMESSAGES)
                    .where(kDbTIMESTAMP, isGreaterThan: timestamp)
                    .count()
                    .get())
                .count;

            //Last message
            DocumentSnapshot docLastMessage = await colCONVERSATIONS
                .doc(d.id)
                .collection(kCollectionMESSAGES)
                .doc('${docData[kDbLASTMESSAGETIME]}')
                .get();
            Map<String, dynamic> dataC = {};
            if (docLastMessage.data() != null) {
              dataC = docLastMessage.data() as Map<String, dynamic>;
              dataC[kDbCONTENT] = ChatHelper.decrypt(
                  conversation.data[kDbENCRYPTKEY], dataC[kDbCONTENT]);
            }
            conversation.lastMessage = dataC;

            cons.add(conversation);
          } else {
            conversation.unread = 0;
            conversation.isEmptyMessages = true;
            conversation.lastMessage = {};
            cons.add(conversation);
          }
        }
      }

      emit(state.update(
        isLoading: false,
        isLoadingInitialize: false,
        conversations: cons,
      ));

      _converstationsSubscription?.cancel();
      _converstationsSubscription = colCONVERSATIONS
          .where(kDbMEMBERSFIREBASEID, arrayContains: loggedFirebaseId)
          .snapshots()
          .listen((snapshot) async {
        AggregateQuerySnapshot q = await colCONVERSATIONS
            .where(kDbMEMBERSFIREBASEID, arrayContains: loggedFirebaseId)
            .orderBy(kDbLASTMESSAGETIME, descending: true)
            .count()
            .get();
        if (q.count != state.conversations.length) {
          add(ChatListInitEvent(isLoadingInitialize: false));
        }
      });

      for (var d in q.docs) {
        _msgsSubscription.add(
            colCONVERSATIONS.doc(d.id).snapshots().listen((snapshot) async {
          Map? docData = snapshot.data();
          if (docData == null) return;
          if (showConverstaion(docData)) {
            int timestamp = docData[kDbMEMBERSDETAIL]
                    .any((e) => e[kDbFIREBASEID] == loggedFirebaseId)
                ? docData[kDbMEMBERSDETAIL].firstWhere((e) =>
                        e[kDbFIREBASEID] == loggedFirebaseId)[kDbTIMESTAMP] ??
                    0
                : 0;
            ChatListConversation conversation = state.conversations.firstWhere(
                (e) => e.conversationId == d.id,
                orElse: () => ChatListConversation())
              ..conversationId = d.id
              ..userIds = docData[kDbMEMBERSDETAIL]
                  .where((e) => e[kDbFIREBASEID] != loggedFirebaseId)
                  .toList()
              ..conversationType = ChatConversationType.values
                  .byName(docData[kDbCONVERSATIONTYPE])
              ..data = docData;

            if (docData[kDbLASTMESSAGETIME] != null &&
                docData[kDbLASTMESSAGETIME] != 0) {
              conversation.unread = conversation.unread =
                  (await colCONVERSATIONS
                          .doc(d.id)
                          .collection(kCollectionMESSAGES)
                          .where(kDbTIMESTAMP, isGreaterThan: timestamp)
                          .count()
                          .get())
                      .count;
              if (conversation.timestamp != docData[kDbLASTMESSAGETIME]) {
                //Last message
                conversation.timestamp = docData[kDbLASTMESSAGETIME];
                DocumentSnapshot docLastMessage = await colCONVERSATIONS
                    .doc(d.id)
                    .collection(kCollectionMESSAGES)
                    .doc('${docData[kDbLASTMESSAGETIME]}')
                    .get();

                Map<String, dynamic> dataC = {};
                if (docLastMessage.data() != null) {
                  dataC = docLastMessage.data() as Map<String, dynamic>;
                  dataC[kDbCONTENT] = ChatHelper.decrypt(
                      conversation.data[kDbENCRYPTKEY], dataC[kDbCONTENT]);
                }
                conversation.lastMessage = dataC;
                conversation.isEmptyMessages = false;
              }
            } else {
              conversation.unread = 0;
              conversation.isEmptyMessages = true;
              conversation.lastMessage = {};
            }

            List<ChatListConversation> conversations =
                List<ChatListConversation>.from(state.conversations
                        .where((e) => e.conversationId != d.id)) +
                    [conversation];
            conversations.sort((a, b) => b.timestamp > a.timestamp ? 1 : -1);
            add(ChatUpdateListConversationEvent(conversations));
          }
        }));
      }

      _getConnectionStatusUsers(requestUsers);
      Map usersByKeys = await _getUsersByKeys(requestUsers);
      emit(state.update(usersByKeys: usersByKeys));
    } catch (_) {}
  }

  void _getConnectionStatusUsers(List requestUsers) async {
    // List<String> users = requestUsers
    //     .map((e) => e[kDbFIREBASEID]?.toString() ?? "")
    //     .where((e) => e != '')
    //     .toList();
    // if (users.isNotEmpty) {
    //   chatConnectionStatusBloc.add(ConnectionStatusInitEvent(users));
    // }
  }

  Future<Map> _getUsersByKeys(List requestUsers) async {
    Map usersByKeys = state.usersByKeys;
    for (var e in requestUsers) {
      if (state.usersByKeys[e[kDbFIREBASEID]] == null &&
          state.usersByKeys[e[kDbFIREBASEID]] != loggedFirebaseId) {
        if (await checkUserInfoFromFirestore(e[kDbFIREBASEID])) {
          Map<String, dynamic>? data =
              await getUserInfoFromFirestore(e[kDbFIREBASEID]);
          usersByKeys[e[kDbFIREBASEID]] = data;
        }
      }
    }
    return usersByKeys;
  }
}
