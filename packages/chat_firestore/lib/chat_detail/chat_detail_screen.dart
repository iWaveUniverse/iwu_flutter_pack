import 'dart:async';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:_private_core/_private_core.dart';
import '../chat_list/bloc/chat_list_bloc.dart';
import '../options.dart';
import 'bloc/chat_detail_bloc.dart';
import 'package:_iwu_pack_chat_firestore/constant.dart';
import '../chat_helper.dart';
import 'message.dart';

enum ChatConversationType { solo, group }

class ChatDetailParams {
  late ChatConversationType conversationType;
  String? conversationId;

  //Bot infos
  late bool isBot;

  //Solo type
  String? soloFirebaseId;

  //Group type
  List<String>? groupFirebaseIds;

  String? name;
  String? thumbnail;
  int? unread;

  ChatDetailParams(
    this.conversationType, {
    this.conversationId,
    this.soloFirebaseId,
    this.groupFirebaseIds,
    this.name,
    this.thumbnail,
    this.unread,
    this.isBot = false,
  });

  ChatDetailParams.solo({
    this.conversationId,
    this.soloFirebaseId,
    this.name,
    this.thumbnail,
    this.unread,
    this.isBot = false,
  }) {
    conversationType = ChatConversationType.solo;
  }
  ChatDetailParams.group({
    this.conversationId,
    this.groupFirebaseIds,
    this.name,
    this.thumbnail,
    this.unread,
  }) {
    conversationType = ChatConversationType.group;
    isBot = false;
  }
}

class ChatDetailScreen extends StatefulWidget {
  static double get padding => 16;
  static String instanceName = '';

  final ChatDetailParams? params;
  final Widget Function(Widget child, bool isLoadingList, bool isLoadingDetail)?
      chatDetailBackgroundBuilder;
  final Widget Function(ChatDetailState state, bool isBot)?
      chatDetailProfileBuilder;
  final Widget Function(ChatDetailState state, TextEditingController controller,
      FocusNode node, Function() onSend, bool isBot)? chatDetailInputBuilder;

  const ChatDetailScreen({
    Key? key,
    this.params,
    this.chatDetailBackgroundBuilder,
    this.chatDetailProfileBuilder,
    this.chatDetailInputBuilder,
  }) : super(key: key);

  static String route = '/chat_detail';

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  ChatDetailParams? params;
  StreamSubscription? messagesSubscription;
  StreamSubscription? conversationSubscription;

  Widget chatDetailBackgroundBuilder(
      Widget child, bool isLoadingList, bool isLoadingDetail) {
    if (widget.chatDetailBackgroundBuilder != null) {
      return widget.chatDetailBackgroundBuilder!(
          child, isLoadingList, isLoadingDetail);
    } else if (chatOptions.chatDetailBackgroundBuilder != null) {
      return chatOptions.chatDetailBackgroundBuilder!(
          child, isLoadingList, isLoadingDetail);
    }
    return child;
  }

  @override
  void initState() {
    super.initState();
    try {
      GetIt.instance<ChatDetailBloc>(
              instanceName: ChatDetailScreen.instanceName)
          .add(ChatDetailDisposeEvent());
    } catch (_) {}
    ChatDetailScreen.instanceName = ChatHelper.generateConversationId();
    GetIt.instance.registerLazySingleton<ChatDetailBloc>(() => ChatDetailBloc(),
        instanceName: ChatDetailScreen.instanceName);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      params = widget.params ??
          ModalRoute.of(context)!.settings.arguments as ChatDetailParams;
      chatDetailBloc.params = params!;
      chatDetailBloc.add(ChatDetailInitialEvent(
        tickerProvider: this,
        messagesSubscription: (_) => messagesSubscription = _,
        conversationSubscription: (_) => conversationSubscription = _,
      ));
      chatOptions.chatOnInitDetail?.call(this);
      setState(() {});
    });
  }

  @override
  void dispose() {
    messagesSubscription?.cancel();
    conversationSubscription?.cancel();
    chatDetailBloc.add(ChatDetailDisposeEvent());
    chatOptions.chatOnDisposeDetail?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (params == null) {
      return chatDetailBackgroundBuilder(const SizedBox(), false, true);
    }
    return KeyboardDismissOnTap(
      child: KeyboardVisibilityBuilder(builder: (_, isKeyboardVisible) {
        if (isKeyboardVisible) {
          Timer(const Duration(milliseconds: 500), () {
            if (chatDetailBloc.scrollController.hasClients) {
              chatDetailBloc.scrollController.animateTo(
                  chatDetailBloc.scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeIn);
            }
          });
        }
        Widget child = Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                WidgetProfileChat(
                  params: params!,
                  builder: widget.chatDetailProfileBuilder,
                ),
                _buildMessages(),
                Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      key: chatDetailBloc.targetAssistantKey,
                      width: 2,
                      height: 2,
                    ),
                  ],
                ),
                WidgetInputChat(
                  params: params!,
                  builder: widget.chatDetailInputBuilder,
                ),
              ],
            ),
          ],
        );

        return BlocBuilder<ChatListBloc, ChatListState>(
          buildWhen: (previous, current) =>
              previous.isLoading != current.isLoading,
          bloc: chatListBloc,
          builder: (_, stateChatList) {
            return BlocBuilder<ChatDetailBloc, ChatDetailState>(
              bloc: chatDetailBloc,
              buildWhen: (previous, current) =>
                  previous.isLoading != current.isLoading,
              builder: (_, stateChatDetail) {
                return chatDetailBackgroundBuilder(
                    child, stateChatList.isLoading, stateChatDetail.isLoading);
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildMessages() {
    return Expanded(
      child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
        bloc: chatDetailBloc,
        builder: (_, state) {
          List<Message> messages = state.messages;
          messages.sort((a, b) {
            return a.timestamp - b.timestamp;
          });
          if (state.isLoading) return const SizedBox();
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: ChatDetailScreen.padding),
            controller: chatDetailBloc.scrollController,
            reverse: true,
            children: _getGroupedMessages(messages),
          );
        },
      ),
    );
  }

  List<Widget> _getGroupedMessages(List<Message> messages) {
    if (chatOptions.chatDetailGroupedMessagesBuilder != null) {
      return chatOptions.chatDetailGroupedMessagesBuilder!(messages);
    }
    List<Widget> groupedMessages =
        List.from(<Widget>[const SizedBox(height: 20)]);
    groupBy<Message, String>(messages, (msg) {
      String datetime =
          DateTime.fromMillisecondsSinceEpoch(msg.timestamp).formatDateTime();
      int otherMessages = 0;
      List<Message> temp = List.from(messages
          .where((e) =>
              DateTime.fromMillisecondsSinceEpoch(e.timestamp)
                      .formatDateTime() ==
                  datetime &&
              ((msg.doc?.data() ?? msg.tmpDoc) as Map)[kDbFROM] !=
                  ((e.doc?.data() ?? e.tmpDoc) as Map)[kDbFROM] &&
              e.timestamp > msg.timestamp)
          .toList())
        ..sorted((a, b) => a.timestamp - b.timestamp);
      otherMessages = temp.length;
      return '$datetime-${((msg.doc?.data() ?? msg.tmpDoc) as Map)[kDbFROM]}-$otherMessages';
    }).forEach((when, actualMessages) {
      groupedMessages.add(Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            when,
            style: w400TextStyle(
                color: appColors.text.withOpacity(.6), fontSize: 10),
          ),
        ),
      ));
      groupedMessages
          .add(actualMessages.last.widgetMessageOwner(actualMessages));
    });
    return groupedMessages.reversed.toList();
  }
}

class WidgetProfileChat extends StatelessWidget {
  final ChatDetailParams params;
  final Widget Function(ChatDetailState state, bool isBot)? builder;
  const WidgetProfileChat({
    Key? key,
    required this.params,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatDetailBloc, ChatDetailState>(
      bloc: chatDetailBloc,
      builder: (_, state) {
        return KeyedSubtree(
          key: ValueKey('WidgetProfileChat-${state.isLoading}'),
          child: builder?.call(state, params.isBot) ??
              chatOptions.chatDetailProfileBuilder(state, params.isBot),
        );
      },
    );
  }
}

class WidgetInputChat extends StatelessWidget {
  final ChatDetailParams params;
  final Widget Function(ChatDetailState state, TextEditingController controller,
      FocusNode node, Function() onSend, bool isBot)? builder;

  const WidgetInputChat({
    Key? key,
    required this.params,
    this.builder,
  }) : super(key: key);

  TextEditingController get controller => chatDetailBloc.inputController;
  FocusNode get inputFocus => chatDetailBloc.inputFocus;

  void onSend() {
    if (controller.text.trim().isNotEmpty) {
      chatDetailBloc.add(ChatSendMessageEvent(
          type: MessageType.text, text: controller.text.trim()));
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatDetailBloc, ChatDetailState>(
      bloc: chatDetailBloc,
      builder: (_, state) {
        return builder?.call(
                state, controller, inputFocus, onSend, params.isBot) ??
            chatOptions.chatDetailInputBuilder(
                state, controller, inputFocus, onSend, params.isBot);
      },
    );
  }
}
