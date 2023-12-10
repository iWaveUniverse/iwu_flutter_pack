import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';

import 'package:intl/intl.dart';
import 'package:_private_core/_private_core.dart'; 

import 'firestore_resouce/instances.dart';
import 'utils/utils.dart';
import 'chat_detail/chat_detail_screen.dart';

class ChatHelper {
  ChatHelper._();

  //Manage status message sending
  static final Map<String, Future> _messageStatus = <String, Future>{};

  static _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  static getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return _messageStatus[key] ?? true;
  }

  static addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      _messageStatus.remove(key);
    });
    _messageStatus[key] = future;
  }

  //===========
  static String generateConversationId() =>
      "${DateTime.now().millisecondsSinceEpoch}-${generateRandomString(4)}";

  static final _iv = IV.fromLength(16);
  static String generateEncryptKey() => Key.fromSecureRandom(32).base64;

  static String encrypt(key, input) {
    try {
      return Encrypter(AES(Key.fromBase64(key))).encrypt(input, iv: _iv).base64;
    } catch (e) {
      return input;
    }
  }

  static String decrypt(key, input) {
    try {
      return Encrypter(AES(Key.fromBase64(key)))
          .decrypt(Encrypted.from64(input), iv: _iv);
    } catch (e) {
      return input;
    }
  }

  static findConversationById(
      {required String conversationId,
      required ChatConversationType type}) async {
    if (!isLoggedFirebaseAuth()) return;
    QuerySnapshot q = await colConverstations
        .where(kDbCONVERSATIONTYPE,
            isEqualTo: type == ChatConversationType.group ? kDbGroup : kDbSOLO)
        .where(kDbCONVERSATIONID, isEqualTo: conversationId)
        .get();
    if (q.size > 0) {
      return q.docs.first.data();
    }
  }

  static findOrCreateSoloConversation(String firebaseId) async {
    if (!isLoggedFirebaseAuth()) return;
    QuerySnapshot q = await colConverstations
        .where(kDbCONVERSATIONTYPE, isEqualTo: kDbSOLO)
        .where(kDbMEMBERSFIREBASEID, arrayContains: loggedFirebaseId)
        // .where(kDbMEMBERS, arrayContains: peerId)
        .get();
    if (q.docs.any((d) => ((d.data() as Map)[kDbMEMBERSFIREBASEID] as List)
        .contains(firebaseId))) {
      return q.docs
          .firstWhere((d) => ((d.data() as Map)[kDbMEMBERSFIREBASEID] as List)
              .contains(firebaseId))
          .data();
    } else {
      String id = generateConversationId();
      Map<String, dynamic> data = {
        kDbCONVERSATIONID: id,
        kDbCONVERSATIONTYPE: kDbSOLO,
        kDbLASTMESSAGETIME: 0,
        kDbENCRYPTKEY: generateEncryptKey(),
        kDbMEMBERSFIREBASEID: [firebaseId, loggedFirebaseId],
        kDbMEMBERSDETAIL: [
          {
            kDbFIREBASEID: firebaseId,
            kDbTIMESTAMP: 0,
          },
          {
            kDbFIREBASEID: loggedFirebaseId,
            kDbTIMESTAMP: 0,
          }
        ],
      };
      await colConverstations.doc(id).set(data);
      return data;
    }
  }

  static findOrCreateGroupConversation({
    String? conversationId,
    List<String>? groupFirebaseIds,
    String? groupName,
    String? thumbnail,
  }) async {
    if (!isLoggedFirebaseAuth()) return;
    QuerySnapshot q = await colConverstations
        .where(kDbCONVERSATIONTYPE, isEqualTo: kDbGroup)
        .where(kDbCONVERSATIONID, isEqualTo: conversationId ?? '-1')
        .get();
    if (q.size > 0) {
      return q.docs.first.data();
    } else {
      String id = conversationId ?? generateConversationId();
      Map<String, dynamic> data = {
        kDbCONVERSATIONID: id,
        kDbCONVERSATIONTYPE: kDbGroup,
        kDbGROUPNAME: groupName,
        kDbTHUMBNAIL: thumbnail,
        kDbLASTMESSAGETIME: DateTime.now().millisecondsSinceEpoch,
        kDbENCRYPTKEY: generateEncryptKey(),
        kDbMEMBERSFIREBASEID: [...groupFirebaseIds!, loggedFirebaseId],
        kDbMEMBERSDETAIL: [
          ...groupFirebaseIds.map(
            (e) => {
              kDbFIREBASEID: e,
              kDbTIMESTAMP: 0,
            },
          ),
          {
            kDbFIREBASEID: loggedFirebaseId,
            kDbTIMESTAMP: 0,
          }
        ],
      };
      await colConverstations.doc(id).set(data);
      return data;
    }
  }

  static updateConversationInfo(Map? conversationData, data) async {
    if (conversationData == null) return;
    if (!isLoggedFirebaseAuth()) return;
    await colConverstations
        .doc(conversationData[kDbCONVERSATIONID])
        .set(data, SetOptions(merge: true));
  }

  static setFavorite(
      {required String conversationId,
      required bool status,
      conversationData}) async {
    if (!isLoggedFirebaseAuth()) return;
    var doc = conversationData ??
        (await colConverstations.doc(conversationId).get()).data();
    List users = doc[kDbFavorite] ?? [];
    if (status) {
      if (users.contains(loggedFirebaseId)) return;
      users.add(loggedFirebaseId);
    } else {
      if (!users.contains(loggedFirebaseId)) return;
      users.remove(loggedFirebaseId);
    }
    colConverstations
        .doc(conversationId)
        .set({kDbFavorite: users}, SetOptions(merge: true));
  }

  static setLastMessageTime(Map? conversationData, lastTime,
      {alsoMembersDetail = false}) {
    if (!isLoggedFirebaseAuth()) return;
    if (conversationData == null) return;
    Map<String, dynamic> data = {kDbLASTMESSAGETIME: lastTime};
    if (alsoMembersDetail) {
      List members = conversationData[kDbMEMBERSDETAIL];
      members.firstWhere(
              (e) => e[kDbFIREBASEID] == loggedFirebaseId)[kDbTIMESTAMP] =
          lastTime + 1;
      data.addAll({kDbMEMBERSDETAIL: members});
    }
    colConverstations.doc(conversationData[kDbCONVERSATIONID]).update(data);
  }

  static setLastTimeTimestamp(Map? conversationData, [int? timestamp]) async {
    if (conversationData == null) return;
    if (!isLoggedFirebaseAuth()) return;
    List members = conversationData[kDbMEMBERSDETAIL];
    if (members.any((e) => e[kDbFIREBASEID] == loggedFirebaseId)) {
      members.firstWhere(
              (e) => e[kDbFIREBASEID] == loggedFirebaseId)[kDbTIMESTAMP] =
          timestamp ??
              DateTime.now()
                  .add(const Duration(seconds: 1))
                  .millisecondsSinceEpoch;
      await colConverstations
          .doc(conversationData[kDbCONVERSATIONID])
          .update({kDbMEMBERSDETAIL: members});
    }
  }

  static removeConversation(id) async {
    if (!isLoggedFirebaseAuth()) return;
    colConverstations.doc(id).delete();
  }

  static getWhen(DateTime date) {
    DateTime now = DateTime.now();
    String when;
    if (date.isToday()) {
      when = appTranslateText('today');
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      when = appTranslateText('yesterday');
    } else {
      when = DateFormat.MMMd().format(date);
    }
    return when;
  }
}
