import 'dart:async';
import 'dart:io';

import 'package:_iwu_pack_chat_firestore/firestore_resouce/instances.dart';
import 'package:_iwu_pack_chat_firestore/options.dart';
import 'package:_private_core/theme/option_chat.dart';
import 'package:_private_core_network/network_resources/chat/chat_repo.dart';
import 'package:_private_core_network/network_resources/chat/model/chat_message_detault.dart';
import 'package:_private_core_network/network_resources/platform/models/platform_status_chat.dart';
import 'package:_private_core_network/network_resources/platform/platform_repo.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:_iwu_pack_chat_firestore/_iwu_pack_chat_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:_iwu_pack_chat_firestore/utils/app_uploader.dart';
import 'package:_iwu_pack_chat_firestore/utils/utils.dart';
import 'package:_private_core/_private_core.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';
import 'package:get_it/get_it.dart';

import '../../chat_helper.dart';
import '../message.dart';
import '../widgets/widget_message_content.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

ChatDetailBloc get chatDetailBloc =>
    GetIt.instance<ChatDetailBloc>(instanceName: ChatDetailScreen.instanceName);

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final SeenState seenState = SeenState(<String, int>{});
  final ReactionState reactionState = ReactionState(<dynamic, dynamic>{});

  final ValueNotifier<Map> progressUpload = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> messageUpdatedValue =
      ValueNotifier({});
  late ChatDetailParams params;
  late PChatOptions detailChatOptions;
  late ScrollController scrollController = ScrollController();
  late TickerProvider _tickerProvider;
  late GlobalKey targetAssistantKey = GlobalKey();

  final TextEditingController inputController = TextEditingController();
  String get textSelectedInTextField =>
      inputController.selection.textInside(inputController.text);
  final FocusNode inputFocus = FocusNode();

  Map? conversationData;

  Map? soloUserInfo;

  ChatConversationType get conversationType => params.conversationType;

  bool get isSoloType => conversationType == ChatConversationType.solo;

  String get conversationId => conversationData?[kDbCONVERSATIONID] ?? '';

  String get soloUserId => params.isBot
      ? 'bot'
      : isSoloType
          ? params.soloFirebaseId ??
              (conversationData?[kDbMEMBERSFIREBASEID]
                  .firstWhere((e) => e != loggedFirebaseId)) ??
              ''
          : '';

  String get soloUserAvatar {
    if (params.isBot) chatOptions.botThumbnail;
    Map? user = chatListBloc.state.getUserByKeys(soloUserId);
    return user?['thumbnail'] ?? params.thumbnail ?? '';
  }

  String get soloUserDisplayName {
    if (params.isBot) chatOptions.botLabel;
    Map? user = chatListBloc.state.getUserByKeys(soloUserId);
    return user?['displayName'] ?? params.name ?? '';
  }

  String get soloUserUsername {
    Map? user = chatListBloc.state.getUserByKeys(soloUserId);
    return user?['username'] ?? '';
  }

  DocumentReference<Map<String, dynamic>> get _docRef =>
      colCONVERSATIONS.doc(conversationId);

  CollectionReference<Map<String, dynamic>> get _colRef =>
      _docRef.collection(kCollectionMESSAGES);

  ChatDetailBloc() : super(ChatDetailState(messages: [])) {
    on<ChatDetailInitialEvent>(
      _onInitial,
      transformer: restartable(),
    );
    on<ChatDetailDisposeEvent>(_onDispose);
    on<ChatDetailLoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<ChatDeleteMessagesEvent>(_onDeleteMessage);
    on<ChatUpdateMessagesEvent>(_onUpdateMessages);
    on<ChatSendMessageEvent>(_onSendMessage);
    on<ChatDetailReplyMessagesEvent>(_onReplyMessage);
    on<ChatDetailEditMessagesEvent>(_onEditMessage);
    on<ChatDetailEditLastMessagesEvent>(_onEditLastMessage);
    on<ChatDetailResetEditOrReplyEvent>(_onResetState);
    on<ChatDetailSendReactionMessagesEvent>(_onReaction);
    on<ChatDetailUnsendReactionMessagesEvent>(_onRemoveReaction);
    on<ChatDetailCopyMessageEvent>(_onCopyMessage);
    on<ChatDetailPastTextInputEvent>(_onPassText);
    on<ChatDetailShowMessageActionsEvent>(_onShowMessageAction);
    on<ChatDetailResetShowMessageActionsEvent>(_onResetShowMessageAction);
  }
  _onShowMessageAction(event, Emitter<ChatDetailState> emit) async {
    emit(state.update(
        isShowMessageActions: true, messageActionDoc: event.messageActionDoc));
  }

  _onResetShowMessageAction(event, Emitter<ChatDetailState> emit) async {
    emit(state.update(isShowMessageActions: false));
  }

  _onPassText(event, Emitter<ChatDetailState> emit) {
    if (event.text != null) {
      inputController.text += event.text;
      inputFocus.requestFocus();
      inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: inputController.text.length));
    }
  }

  _onCopyMessage(event, Emitter<ChatDetailState> emit) {
    Clipboard.setData(ClipboardData(
        text:
            ChatHelper.decrypt(conversationData![kDbENCRYPTKEY], event.text)));
  }

  _onRemoveReaction(ChatDetailUnsendReactionMessagesEvent event,
      Emitter<ChatDetailState> emit) async {
    Map<String, dynamic> data = (event.doc[kDbREACTIONS] ?? {});
    data.remove(loggedFirebaseId);
    _colRef
        .doc('${event.doc[kDbTIMESTAMP]}')
        .set({kDbREACTIONS: data}, SetOptions(merge: true));
  }

  _onReaction(ChatDetailSendReactionMessagesEvent event,
      Emitter<ChatDetailState> emit) async {
    Map<String, dynamic> data = (event.doc[kDbREACTIONS] ?? {});
    data.addAll({loggedFirebaseId: event.value});
    _colRef
        .doc('${event.doc[kDbTIMESTAMP]}')
        .set({kDbREACTIONS: data}, SetOptions(merge: true));
  }

  _onResetState(ChatDetailResetEditOrReplyEvent event,
      Emitter<ChatDetailState> emit) async {
    emit(state.update(isEditKeyboard: false, isReplyKeyboard: false));
  }

  _onEditLastMessage(event, Emitter<ChatDetailState> emit) async {
    if (state.messages.any((e) =>
        (e.tmpDoc != null && e.tmpDoc![kDbFROM] == loggedFirebaseId) ||
        (e.doc != null && e.doc![kDbFROM] == loggedFirebaseId))) {
      var message = state.messages.lastWhere((e) =>
          (e.tmpDoc != null && e.tmpDoc![kDbFROM] == loggedFirebaseId) ||
          (e.doc != null && e.doc![kDbFROM] == loggedFirebaseId));
      inputFocus.unfocus();
      Map<String, dynamic> editDoc = message.data;
      if (editDoc[kDbMESSAGETYPE] == MessageType.text.index) {
        Timer(const Duration(milliseconds: 500), () {
          add(ChatDetailEditMessagesEvent(editDoc));
        });
      }
    }
  }

  _onEditMessage(
      ChatDetailEditMessagesEvent event, Emitter<ChatDetailState> emit) async {
    inputController.text = ChatHelper.decrypt(
        conversationData![kDbENCRYPTKEY], event.editDoc[kDbCONTENT]);
    inputFocus.requestFocus();
    inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length));
    emit(state.update(
        editDoc: event.editDoc, isEditKeyboard: true, isReplyKeyboard: false));
  }

  _onReplyMessage(
      ChatDetailReplyMessagesEvent event, Emitter<ChatDetailState> emit) async {
    inputFocus.requestFocus();
    emit(state.update(
        replyDoc: event.repllyDoc,
        isEditKeyboard: false,
        isReplyKeyboard: true));
  }

  _onUploadProgress(
      String fileName, MessageType type, TaskSnapshot taskSnapshot) async {
    switch (taskSnapshot.state) {
      case TaskState.running:
        final progress =
            100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        progressUpload.value = {
          'fileName': fileName,
          'messageType': type.index,
          'progress': progress.toInt()
        };
        appDebugPrint("Upload is $progress% complete.");
        break;
      case TaskState.paused:
        appDebugPrint("Upload is paused.");
        break;
      case TaskState.canceled:
        appDebugPrint("Upload was canceled");
        progressUpload.value = {};
        break;
      case TaskState.error:
        appDebugPrint("Upload was error");
        progressUpload.value = {};
        break;
      case TaskState.success:
        appDebugPrint("Upload was success");
        Timer(const Duration(milliseconds: 200), () {
          progressUpload.value = {};
        });
        break;
      default:
        Timer(const Duration(milliseconds: 200), () {
          progressUpload.value = {};
        });
        break;
    }
  }

  String _tempMessageContent(MessageType messageType, text, sender) {
    switch (messageType) {
      case MessageType.gif:
      case MessageType.image:
        return '$sender: an image';
      case MessageType.audio:
        return '$sender: an audio';
      case MessageType.lottie:
        return '$sender: a smile';
      default:
        return '$sender: $text';
    }
  }

  _onSendMessage(
      ChatSendMessageEvent event, Emitter<ChatDetailState> emit) async {
    String? assetUrl;
    String? assetExt;
    String? assetFileName;
    String? assetFileMime;
    int? assetFileDuration;
    if (!params.isBot) {
      if (event.type == MessageType.gif) {
        assetExt = 'gif';
        assetFileName = '';
        assetFileMime = 'image/gif';
        assetUrl = event.text;
      } else if (event.type == MessageType.audio) {
        assetExt = event.imageExt;
        assetFileName = event.imageFileName;
        assetFileMime = event.imageFileMime;
        assetFileDuration = event.assetFileDuration;
        assetUrl = await AppUploader.uploadFile(
          data: event.imageData!,
          path: 'conversations/$conversationId',
          userId: loggedFirebaseId,
          meta: SettableMetadata(contentType: assetFileMime),
          onUploading: (task) {
            _onUploadProgress(assetFileName ?? '', event.type, task);
          },
        );
      } else if (event.type == MessageType.image) {
        if (event.imageData != null) {
          assetExt = event.imageExt;
          assetFileName = event.imageFileName;
          assetFileMime = event.imageFileMime;
          assetUrl = await AppUploader.uploadFile(
            data: event.imageData!,
            path: 'conversations/$conversationId',
            userId: loggedFirebaseId,
            meta: SettableMetadata(contentType: assetFileMime),
            isNeedCompress: true,
            onUploading: (task) {
              _onUploadProgress(assetFileName ?? '', event.type, task);
            },
          );
        } else {
          // File? image = event.image ??
          //     await chatOptions.takeFile!(
          //         fileType: PTakeFileType.single,
          //         fileTypeAllow: PTakeFileTypeAllow.image);
          // if (image == null) return;
          // assetExt = p.extension(image.path);
          // assetFileName = p.basename(image.path);
          // assetFileMime = lookupMimeType(image.path);
          // assetUrl = await AppUploader.uploadFile(
          //   file: image,
          //   path: 'conversations/$conversationId',
          //   meta: SettableMetadata(contentType: assetFileMime),
          //   userId: loggedFirebaseId,
          //   onUploading: (task) {
          //     _onUploadProgress(assetFileName ?? '', event.type, task);
          //   },
          // );
        }
      } else if (state.isEditKeyboard) {
        String content =
            ChatHelper.encrypt(conversationData![kDbENCRYPTKEY], event.text);
        _colRef.doc('${state.editDoc![kDbTIMESTAMP]}').update({
          kDbISEDITTED: true,
          kDbCONTENT: content,
        });
        add(ChatDetailResetEditOrReplyEvent());
        return;
      }
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      bool isEnableNotif = event.isEnableNotif ?? true;
      String content =
          ChatHelper.encrypt(conversationData![kDbENCRYPTKEY], event.text);
      Map<String, dynamic> data = {
        kDbCHATID: conversationId,
        kDbFROM: loggedFirebaseId,
        kDbTIMESTAMP: timestamp,
        kDbCONTENT: content,
        kDbMESSAGETYPE: event.type.index,
        kDbISREPLY: state.isReplyKeyboard && event.type != MessageType.image,
        kDbREPLYDOC: state.replyDoc,
        kDbISENABLENOTIF: isEnableNotif,
        kDbPLATFORMID: valuePlatformByConfig(),
        kDbCUSTOMDATA: event.customData,
      };
      if (isEnableNotif) {
        data.addAll({
          kDbBODYNOTIF: event.bodyNotif ??
              _tempMessageContent(
                  event.type, event.text, appPrefs.loginUser!.displayName),
        });
      }
      if (assetUrl != null) {
        data.addAll({
          kDbCONTENTURL: assetUrl,
          kDbCONTENTFILEINFOS: {
            kDbFILEEXT: assetExt,
            kDbFILEFILENAME: assetFileName,
            kDbFILEMIME: assetFileMime,
            kDbFILEDURATION: assetFileDuration,
          },
        });
      }
      ChatHelper.setLastMessageTime(conversationData, timestamp,
          alsoMembersDetail: true);

      List<Message> messages = state.messages;
      if (isSoloType) {
        if (messages.isEmpty) {
          ChatHelper.updateConversationInfo(conversationData, {
            "firstMessage": {
              kDbFROM: loggedFirebaseId,
              kDbTIMESTAMP: timestamp,
              kDbCONTENT: content,
              kDbMESSAGETYPE: event.type.index,
              kDbPLATFORMID: valuePlatformByConfig(),
              kDbCUSTOMDATA: event.customData,
            }
          });
        } else if (!messages.any((e) => e.data[kDbFROM] == loggedFirebaseId)) {
          ChatHelper.updateConversationInfo(conversationData, {
            "firstMessageAnswer": {
              kDbFROM: loggedFirebaseId,
              kDbTIMESTAMP: timestamp,
              kDbCONTENT: content,
              kDbMESSAGETYPE: event.type.index,
              kDbPLATFORMID: valuePlatformByConfig(),
              kDbCUSTOMDATA: event.customData,
            }
          });
        }
      }
      Future messaging = _colRef
          .doc('$timestamp')
          .set(data, SetOptions(merge: true))
          .then((e) {
        if (isEnableNotif) {
          _colRef.doc('$timestamp').update({kDbBODYNOTIF: FieldValue.delete()});
        }
      });

      ChatHelper.addMessage(soloUserId, timestamp, messaging);

      Message m = Message(
        tmpDoc: data,
        animationController: AnimationController(
          duration: _messageAnimationDuration,
          reverseDuration: _messageReverseAnimationDuration,
          vsync: _tickerProvider,
        ),
        timestamp: timestamp,
        widgetMessageOwner: (messages) => _builderProvider(
          timestamp: timestamp,
          child: WidgetMessageOwner(
            messages: messages,
            data: data,
            peerId: data[kDbFROM],
            toPeerId: soloUserId,
            delivered: ChatHelper.getMessageStatus(soloUserId, timestamp),
          ),
        ),
      )..animationController.forward();

      messages.add(m);

      emit(state.update(messages: messages));
      add(ChatDetailResetEditOrReplyEvent());
    } else {
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String content = event.text;
      Map<String, dynamic> data = {
        kDbTIMESTAMP: timestamp,
        kDbCONTENT: content,
        kDbMESSAGETYPE: event.type.index,
        kDbFROM: loggedFirebaseId,
      };

      List<Message> messages = state.messages;

      Message m = Message(
        tmpDoc: data,
        animationController: AnimationController(
          duration: _messageAnimationDuration,
          reverseDuration: _messageReverseAnimationDuration,
          vsync: _tickerProvider,
        ),
        timestamp: timestamp,
        widgetMessageOwner: (messages) => _builderProvider(
          timestamp: timestamp,
          child: WidgetMessageOwner(
            messages: messages,
            data: data,
            peerId: data[kDbFROM],
            toPeerId: soloUserId,
            delivered: ChatHelper.getMessageStatus(soloUserId, timestamp),
          ),
        ),
      )..animationController.forward();

      messages.add(m);

      emit(state.update(messages: messages));
      add(ChatDetailResetEditOrReplyEvent());

      String? answer = await chatOptions.botGetAnswer!(content);
      if (answer != null) {
        var timestamp = DateTime.now().millisecondsSinceEpoch;
        Map<String, dynamic> data = {
          kDbTIMESTAMP: timestamp,
          kDbCONTENT: answer,
          kDbMESSAGETYPE: event.type.index,
          kDbFROM: soloUserId,
        };
        var messages = state.messages;

        m = Message(
          tmpDoc: data,
          animationController: AnimationController(
            duration: _messageAnimationDuration,
            reverseDuration: _messageReverseAnimationDuration,
            vsync: _tickerProvider,
          ),
          timestamp: timestamp,
          widgetMessageOwner: (messages) => _builderProvider(
            timestamp: timestamp,
            child: WidgetMessageOwner(
              messages: messages,
              data: data,
              peerId: data[kDbFROM],
              toPeerId: loggedFirebaseId,
              delivered: ChatHelper.getMessageStatus(soloUserId, timestamp),
            ),
          ),
        )..animationController.forward();

        messages.add(m);

        emit(state.update(messages: messages));
      }
    }
  }

  _onDispose(
      ChatDetailDisposeEvent event, Emitter<ChatDetailState> emit) async {
    chatDetailAssetBloc.add(DisposeChatDetailAssetEvent());
    if (_typing == true) {
      chatConnectionStatusBloc.add(ConnectionStatusSetStatusEvent(
          conversationStatus: ConversationStatus.none));
    }
    state.messages.clear();
    ChatHelper.setLastTimeTimestamp(conversationData);
  }

  _onUpdateMessages(
      ChatUpdateMessagesEvent event, Emitter<ChatDetailState> emit) {
    emit(state.update());
  }

  _onDeleteMessage(
      ChatDeleteMessagesEvent event, Emitter<ChatDetailState> emit) {
    _deleteMessage(event.timestamp);
    emit(state.update());
  }

  bool _typing = false;
  Timer? _debounce;

  _onInitial(
      ChatDetailInitialEvent event, Emitter<ChatDetailState> emit) async {
    if (!isLoggedFirebaseAuth()) return;
    emit(state.update(
        isLoading: true, isEditKeyboard: false, isReplyKeyboard: false));
    // if (!kIsWeb) {
    //   inputController.text = appPrefs.getDraftMessage(conversationId);
    // }
    conversationData = null;
    _tickerProvider = event.tickerProvider!;
    if (!params.isBot) {
      inputController.addListener(() {
        if (inputController.text.isNotEmpty && _typing == false) {
          chatConnectionStatusBloc.add(ConnectionStatusSetStatusEvent(
              conversationStatus: ConversationStatus.typing,
              conversationId: conversationId));
          _typing = true;
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(seconds: 15), () {
            chatConnectionStatusBloc.add(ConnectionStatusSetStatusEvent(
                conversationStatus: ConversationStatus.none));
            _typing = false;
          });
        }
        if (inputController.text.isEmpty && _typing == true) {
          chatConnectionStatusBloc.add(ConnectionStatusSetStatusEvent(
              conversationStatus: ConversationStatus.none));
          _typing = false;
        }
      });
      if (params.conversationId != null) {
        conversationData = await ChatHelper.findConversationById(
            conversationId: params.conversationId!, type: conversationType);
      }

      //Get user info if it's solo type
      Future a() async {
        if (isSoloType &&
            params.soloFirebaseId != null &&
            params.soloFirebaseId != "" &&
            await checkUserInfoFromFirestore(params.soloFirebaseId)) {
          chatConnectionStatusBloc.add(ConnectionStatusInitEvent(
              [loggedFirebaseId, params.soloFirebaseId!]));
          soloUserInfo = await getUserInfoFromFirestore(params.soloFirebaseId);
          if (soloUserInfo?['username'] != null &&
              soloUserInfo?['isAnonymously'] != 1) {
            PlatformStatusChat? statusChat = await PlatformRepo()
                .getStatusChatForPlatformId(
                    {'username': soloUserInfo!['username']});
            state.statusChat = statusChat;
            state.defaultMessage = null;
            if (statusChat?.id == 5) {
              ChatMessageDefault? defaultMessage = await ChatRepo()
                  .getDefaultMessagesForChat(
                      {'username': soloUserInfo!['username']});
              state.defaultMessage = defaultMessage;
            }
          }
        }
      }

      Future b() async {
        conversationData ??= isSoloType
            ? await ChatHelper.findOrCreateSoloConversation(
                params.soloFirebaseId!)
            : await ChatHelper.findOrCreateGroupConversation(
                conversationId: params.conversationId,
                groupFirebaseIds: params.groupFirebaseIds,
                groupName: params.name,
                thumbnail: params.thumbnail,
              );
      }

      await Future.wait([a(), b()]);

      emit(state.update(isLoading: false));
      if (conversationData == null) {
        return;
      }

      if (conversationData?[kDbMEMBERSFIREBASEID] != null &&
          conversationData![kDbMEMBERSFIREBASEID]!.isNotEmpty) {
        chatListBloc.add(LoadUserInfoConversationEvent(
            conversationData?[kDbMEMBERSFIREBASEID]));
      }

      ChatHelper.setLastTimeTimestamp(conversationData);

      event.conversationSubscription(
          _docRef.snapshots().listen((DocumentSnapshot d) {
        conversationData = d.data() as Map?;
        if (conversationData == null) return;
        List members = conversationData![kDbMEMBERSDETAIL];
        Map<String, dynamic> _ = {};
        for (var e in members) {
          _.addAll({e[kDbFIREBASEID]: e[kDbTIMESTAMP] ?? 0});
        }
        seenState.value = _;
        add(ChatUpdateMessagesEvent());
      }));

      List<Message> messages = <Message>[];
      await _colRef
          .orderBy(kDbTIMESTAMP)
          .limitToLast(kNumberLimitMessages)
          .get()
          .then((docs) async {
        bool isEmpty = !docs.docs.isNotEmpty;
        if (docs.docs.isNotEmpty) {
          for (var queryDoc in docs.docs) {
            Map<String, dynamic> queryDocData = Map.from(queryDoc.data());
            int timestamp = queryDocData[kDbTIMESTAMP];
            Message m = Message(
                doc: queryDoc,
                animationController: AnimationController(
                  value: 1,
                  duration: _messageAnimationDuration,
                  reverseDuration: _messageReverseAnimationDuration,
                  vsync: _tickerProvider,
                ),
                widgetMessageOwner: (messages) => _builderProvider(
                      timestamp: timestamp,
                      child: WidgetMessageOwner(
                        messages: messages,
                        data: queryDocData,
                        peerId: queryDocData[kDbFROM],
                        toPeerId: soloUserId,
                        delivered:
                            ChatHelper.getMessageStatus(soloUserId, timestamp),
                      ),
                    ),
                timestamp: timestamp);
            messages.add(m);
            Map<dynamic, dynamic> _ = Map.from(reactionState.value);
            _.addAll({queryDoc.id: queryDocData[kDbREACTIONS]});
            reactionState.value = _;
          }
        }
        emit(state.update(messages: messages, isLoading: false));

        _isLoadingMore = false;

        chatDetailAssetBloc.add(InitChatDetailAssetEvent(conversationData));
        // chatListBloc.add(ChatListInitEvent());

        event.messagesSubscription(_colRef.snapshots().listen((query) async {
          if (isEmpty ||
              query.docs.length != query.docChanges.length ||
              query.docChanges
                  .where((doc) =>
                      doc.type == DocumentChangeType.modified ||
                      doc.type == DocumentChangeType.removed)
                  .isNotEmpty) {
            List<Message> messages = state.messages;
            //----below action triggers when peer new message arrives
            query.docChanges.where((doc) {
              return doc.oldIndex <= doc.newIndex &&
                  doc.type == DocumentChangeType.added &&
                  (doc.doc.data() as Map)[kDbFROM] != loggedFirebaseId;
            }).forEach((change) {
              Map<String, dynamic> queryDocData = Map.from(change.doc.data()!);
              appDebugPrint('DocumentChangeType.received: $queryDocData');
              int timestamp = queryDocData[kDbTIMESTAMP];
              Message m = Message(
                doc: change.doc,
                animationController: AnimationController(
                  duration: _messageAnimationDuration,
                  reverseDuration: _messageReverseAnimationDuration,
                  vsync: _tickerProvider,
                ),
                timestamp: timestamp,
                widgetMessageOwner: (messages) => _builderProvider(
                  timestamp: timestamp,
                  child: WidgetMessageOwner(
                    messages: messages,
                    data: queryDocData,
                    peerId: queryDocData[kDbFROM],
                    toPeerId: soloUserId,
                    delivered:
                        ChatHelper.getMessageStatus(soloUserId, timestamp),
                  ),
                ),
              )..animationController.forward();
              messages.add(m);
              ChatHelper.setLastTimeTimestamp(conversationData);
            });
            //----below action triggers when peer message get deleted
            query.docChanges
                .where((doc) => doc.type == DocumentChangeType.removed)
                .forEach((change) {
              Map<String, dynamic> queryDocData = Map.from(change.doc.data()!);
              appDebugPrint('DocumentChangeType.removed: $queryDocData');
              if (messages
                  .any((e) => e.timestamp == queryDocData[kDbTIMESTAMP])) {
                _deleteMessage(
                    messages
                        .firstWhere(
                            (e) => e.timestamp == queryDocData[kDbTIMESTAMP])
                        .timestamp,
                    isOnlyLocal: true);
              }
            });

            //----below action triggers when peer message get update: edit or reaction..
            query.docChanges
                .where((doc) => doc.type == DocumentChangeType.modified)
                .forEach((change) {
              Map<String, dynamic> data = Map.from(change.doc.data()!);
              // appDebugPrint('DocumentChangeType.modified: $_doc');

              //Reactions
              Map<dynamic, dynamic> _ = Map.from(reactionState.value);
              _.addAll({change.doc.id: data[kDbREACTIONS]});
              reactionState.value = _;

              // Update real content
              Map<String, dynamic> y = Map.from(messageUpdatedValue.value);
              y.addAll({
                change.doc.id: ChatHelper.decrypt(
                    conversationData![kDbENCRYPTKEY], data[kDbCONTENT])
              });
              messageUpdatedValue.value = y;

              if (messages.any((e) => e.timestamp == data[kDbTIMESTAMP])) {
                messages
                    .firstWhere((e) => e.timestamp == data[kDbTIMESTAMP])
                    .tmpDoc = null;
                messages
                    .firstWhere((e) => e.timestamp == data[kDbTIMESTAMP])
                    .doc = change.doc;
              }
            });

            isEmpty = messages.isEmpty;
            add(ChatUpdateMessagesEvent());
          }
        }));
        scrollController.removeListener(_scrollListener);
        scrollController.addListener(_scrollListener);
      });
    } else {
      emit(state.update(messages: [], isLoading: false));
    }
    event.callback?.call();
  }

  _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent) {
      add(ChatDetailLoadMoreMessagesEvent());
    }
  }

  bool _isLoadingMore = false;
  _onLoadMoreMessages(ChatDetailLoadMoreMessagesEvent event,
      Emitter<ChatDetailState> emit) async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    _colRef
        .orderBy(kDbTIMESTAMP)
        .endBefore([state.messages.first.timestamp])
        .get()
        .then((docs) {
          if (docs.docs.isNotEmpty) {
            List<QueryDocumentSnapshot<Map>> d = List.from(docs.docs);
            if (d.length > kNumberLimitMessages) {
              d = d
                  .getRange(d.length - kNumberLimitMessages, d.length)
                  .toList();
            }
            d.sort((a, b) {
              Map<String, dynamic> docA = Map.from(a.data());
              Map<String, dynamic> docB = Map.from(b.data());
              return docB[kDbTIMESTAMP] - docA[kDbTIMESTAMP];
            });
            List<Message> messages = List.from(state.messages);
            for (var queryDoc in d) {
              Map<String, dynamic> queryDocData = Map.from(queryDoc.data());
              int timestamp = queryDocData[kDbTIMESTAMP];
              Message m = Message(
                  doc: queryDoc,
                  animationController: AnimationController(
                    value: 1,
                    duration: _messageAnimationDuration,
                    reverseDuration: _messageReverseAnimationDuration,
                    vsync: _tickerProvider,
                  ),
                  widgetMessageOwner: (messages) => _builderProvider(
                        timestamp: timestamp,
                        child: WidgetMessageOwner(
                          messages: messages,
                          data: queryDocData,
                          peerId: queryDocData[kDbFROM],
                          toPeerId: soloUserId,
                          delivered: ChatHelper.getMessageStatus(
                              soloUserId, timestamp),
                        ),
                      ),
                  timestamp: timestamp);
              Map<dynamic, dynamic> _ = Map.from(reactionState.value);
              _.addAll({queryDoc.id: queryDocData[kDbREACTIONS]});
              reactionState.value = _;
              messages.insert(0, m);
            }
            state.messages = messages;
            add(ChatUpdateMessagesEvent());
            Timer(const Duration(seconds: 2), () {
              _isLoadingMore = false;
            });
          }
        });
  }

  void _deleteMessage(timestamp, {bool isOnlyLocal = false}) {
    bool isExisting = state.messages.any((msg) => msg.timestamp == timestamp);
    if (isExisting) {
      messageByTimestamp(timestamp).animationController.reverse();
      Timer(Duration(milliseconds: isExisting ? 500 : 100), () {
        List<Message> messages = List.from(state.messages);
        messages.removeWhere((msg) => msg.timestamp == timestamp);
        state.messages = messages;
        if (!isOnlyLocal) _colRef.doc('$timestamp').delete();
        ChatHelper.setLastMessageTime(
            conversationData, messages.last.timestamp);
      });
    }
  }

  Message messageByTimestamp(timestamp) =>
      state.messages.firstWhere((msg) => msg.timestamp == timestamp);

  Widget _builderProvider({timestamp, child}) {
    return MessageStateProvider(
      reactionState: reactionState,
      seenState: seenState,
      child: child,
    );
  }
}

const Duration _messageAnimationDuration = Duration(milliseconds: 350);
const Duration _messageReverseAnimationDuration = Duration(milliseconds: 150);
