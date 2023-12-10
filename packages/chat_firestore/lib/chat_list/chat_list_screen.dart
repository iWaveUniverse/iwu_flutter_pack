import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'bloc/chat_list_bloc.dart';

class ChatListScreen extends StatefulWidget {
  final Widget Function(ChatListState state) builder;
  final bool needCallInit;
  final bool needCallDispose;
  const ChatListScreen({
    Key? key,
    required this.builder,
    this.needCallInit = true,
    this.needCallDispose = true,
  }) : super(key: key);

  static String route = '/chat_list';

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.needCallInit) {
      chatListBloc.add(ChatListInitEvent());
    }
  }

  @override
  void dispose() {
    if (widget.needCallDispose) {
      chatListBloc.add(ChatListDisposeEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      bloc: chatListBloc,
      builder: (_, state) {
        return widget.builder(state);
      },
    );
  }
}



// class WidgetConversationItem extends StatelessWidget {
//   final ChatListConversation m;
//   const WidgetConversationItem({
//     Key? key,
//     required this.m,
//   }) : super(key: key);

//   TextStyle get styleName => w500TextStyle().copyWith(fontSize: 14);
//   TextStyle get styleMessage =>
//       w300TextStyle().copyWith(fontSize: 12, color: hexColor('#99A4AC'));
//   TextStyle get styleTime => w500TextStyle().copyWith(fontSize: 10);

//   int get unread => m.unread;
//   String get fullname {
//     switch (m.conversationType) {
//       case ChatConversationType.solo:
//         Map? user = chatListBloc
//             .state
//             .usersByKeys[m.userIds.first[kDbUSERNAME]];
//         return chatGetFullNameUser(user);

//       case ChatConversationType.group:
//         return m.data[kDbGROUP_NAME] ?? '';
//     }
//   }

//   String get username {
//     switch (m.conversationType) {
//       case ChatConversationType.solo:
//         Map? user = chatListBloc
//             .state
//             .usersByKeys[m.userIds.first[kDbUSERNAME]];
//         return chatGetUsernameUser(user);

//       case ChatConversationType.group:
//         return '';
//     }
//   }

//   String get thumbnail {
//     switch (m.conversationType) {
//       case ChatConversationType.solo:
//         Map? user = chatListBloc
//             .state
//             .usersByKeys[m.userIds.first[kDbUSERNAME]];
//         return chatGetThumbnailUser(user);

//       case ChatConversationType.group:
//         return m.data[kDbTHUMBNAIL] ?? '';
//     }
//   }

//   String get msg {
//     String _ = m.lastMessage[kDbCONTENT] ?? 'groupcreated'.tr;
//     if (m.lastMessage[kDbCONTENT_URL] != null) {
//       _ = 'attach'.tr;
//     }
//     return _;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: (unread > 0)
//           ? BoxDecoration(color: hexColor('#1F2026'))
//           : const BoxDecoration(),
//       child: InkWell(
//         onTap: () {
//           chatListBloc.add(ChatListReadItemEvent(c: m));
//         },
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Hero(
//               tag: m.conversationId,
//               child: WidgetAppImage(
//                 imageUrl: thumbnail,
//                 width: 26 * 2,
//                 height: 26 * 2,
//                 radius: 26 * 2,
//                 errorWidget: CircleAvatar(
//                     backgroundImage: AssetImage(assetjpg('defaultavatar'),
//                         package: '_private_core')),
//               ),
//             ),
//             const SizedBox(
//               width: 15,
//             ),
//             Flexible(
//               fit: FlexFit.tight,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Flexible(
//                         fit: FlexFit.tight,
//                         child: Text(
//                           fullname,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: styleName,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 4,
//                       ),
//                       Text(
//                         timeago.format(
//                           DateTime.fromMillisecondsSinceEpoch(
//                               m.lastMessage[kDbTIMESTAMP] ??
//                                   m.data[kDbLAST_MESSAGE_TIME]),
//                         ),
//                         style: styleTime,
//                       )
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 6,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: !kIsWeb &&
//                                 appPrefs
//                                     .getDraftMessage(m.conversationId)
//                                     .trim()
//                                     .isNotEmpty
//                             ? Text(
//                                 'draft'.tr,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: styleMessage.copyWith(color: mainColor),
//                               )
//                             : Text(
//                                 msg,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: styleMessage,
//                               ),
//                       ),
//                       if (unread > 0)
//                         CircleAvatar(
//                           backgroundColor: hexColor('#3E61F7'),
//                           radius: 7,
//                           child: Padding(
//                             padding: const EdgeInsets.all(2.0),
//                             child: FittedBox(
//                               child: Text(
//                                 '$unread',
//                                 style: w700TextStyle()
//                                     .copyWith(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
