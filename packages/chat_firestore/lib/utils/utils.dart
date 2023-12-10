import 'dart:math';

import 'package:_private_core/_private_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat_helper.dart';
import '../chat_detail/message.dart';
import '../constant.dart';
import '../firestore_resouce/instances.dart';

bool isLoggedFirebaseAuth() {
  bool logged = FirebaseAuth.instance.currentUser != null;
  if (!logged) {
    appDebugPrint('[isLoggedFirebaseAuth] false');
  }
  return logged;
}

Map<String, dynamic> kDefaultUserInfo(firebaseId) => {
      "username": "anonymous",
      "displayName": "Anonymous",
      "firebaseId": firebaseId,
      "isPro": 0,
      "thumbnail": "/thumbnails/default/user.jpg",
      "uniqueId": "Uanonymous",
      "isAnonymously": 1,
    };

int getTimestamp(data) => data[kDbTIMESTAMP];

String getContent(key, data) => ChatHelper.decrypt(key, data[kDbCONTENT]);

bool getIsMe(data) => data[kDbFROM] == loggedFirebaseId;

bool get isLoggedAnonymous => appPrefs.loginUser?.id == null;

String get loggedUsername => appPrefs.loginUser?.username ?? '';

String get loggedFirebaseId => appPrefs.loginUser?.firebaseId ?? '';

Future<bool> checkUserInfoFromFirestore(String? firebaseId) async {
  return (firebaseId != null &&
      firebaseId != "" &&
      (await colUSERS.doc(firebaseId).get()).exists);
}

Future<Map<String, dynamic>> getUserInfoFromFirestore(
    String? firebaseId) async {
  if (firebaseId != null &&
      firebaseId != "" &&
      (await colUSERS.doc(firebaseId).get()).exists) {
    return (await colUSERS.doc(firebaseId).get()).data() ??
        kDefaultUserInfo(firebaseId);
  }
  return kDefaultUserInfo(firebaseId);
}

Future<Map> getStatisticFirstMessage(int platformId) async {
  QuerySnapshot q = await colConverstations
      .where(kDbMEMBERSFIREBASEID, arrayContains: loggedFirebaseId)
      .orderBy(kDbLASTMESSAGETIME, descending: true)
      .get();
  var totalfirstMessage = 0;
  var totalfirstMessageAnswer = 0;
  var totalfirstMessageAnswerTime = 0;
  for (var d in q.docs) {
    Map docData = d.data() as Map;
    if (docData['firstMessage'] != null &&
        docData['firstMessage'][kDbPLATFORMID] == platformId &&
        docData['firstMessage'][kDbFROM] != loggedFirebaseId) {
      totalfirstMessage++;

      if (docData['firstMessageAnswer'] != null &&
          docData['firstMessageAnswer'][kDbFROM] == loggedFirebaseId) {
        if ((docData['firstMessageAnswer'][kDbTIMESTAMP] as int) >
            (docData['firstMessage'][kDbTIMESTAMP] as int)) {
          totalfirstMessageAnswerTime +=
              (docData['firstMessageAnswer'][kDbTIMESTAMP] as int) -
                  (docData['firstMessage'][kDbTIMESTAMP] as int);
        }
        totalfirstMessageAnswer++;
      }
    }
  }
  var result = {
    //in miliseconds
    "averageTimeResponse": totalfirstMessageAnswer == 0
        ? 0
        : totalfirstMessageAnswerTime / totalfirstMessageAnswer,
    "totalfirstMessage": totalfirstMessage,
    "pourcentageMessageResponse": totalfirstMessage == 0
        ? 0
        : ((totalfirstMessageAnswer / totalfirstMessage) * 100)
  };
  return result;
}

Future<Map?> getNextMessage(
    MessageType messageType, conversationId, timestamp) async {
  QuerySnapshot q = await colConverstations
      .doc(conversationId)
      .collection(kCollectionMESSAGES)
      .where(kDbMESSAGETYPE, isEqualTo: messageType.index)
      .where(kDbTIMESTAMP, isGreaterThan: timestamp)
      .limit(1)
      .get();
  if (q.size != 0) {
    return q.docs.single.data() as Map;
  }
  return null;
}

String generateRandomString(int len) {
  var r = Random();
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}
