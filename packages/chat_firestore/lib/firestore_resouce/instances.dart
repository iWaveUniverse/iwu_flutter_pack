import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference<Map<String, dynamic>> get colConverstations =>
    FirebaseFirestore.instance.collection(kCollectionConverstations);

const kNumberLimitMessages = 25;

const String kPrefixCollection = "_iwu_chat_";

//Collections
const String kCollectionMESSAGES = "messages";
const String kCollectionConverstations = "${kPrefixCollection}conversations";

//Key data in firestore
const String kDbTIMESTAMP = 'timestamp';
const String kDbCONTENT = 'content';
const String kDbCONTENTURL = 'contentUrl';
const String kDbCONTENTFILEINFOS = 'contentFileInfos';
const String kDbFILEEXT = 'ext';
const String kDbFILEFILENAME = 'fileName';
const String kDbFILEMIME = 'mime';
const String kDbFILEDURATION = 'duration';
const String kDbFROM = 'from';
const String kDbCHATSTATUS = 'chatStatus';
const String kDbCHATID = 'chatId';
const String kDbMESSAGETYPE = 'messageType';
const String kDbLASTMESSAGETIME = 'lastMessageTime';
const String kDbSTATUS = 'status';
const String kDbPICKEDAT = 'pickedAt';
const String kDbENDAT = 'endAt';
const String kDbCALLINFO = 'callInfo';
const String kDbREACTIONS = 'reactions';
const String kDbISREPLY = 'isReply';
const String kDbISEDITTED = 'isEditted';
const String kDbREPLYDOC = 'replyDoc';
const String kDbCUSTOMDATA = 'customData';
const String kDbFIREBASEID = 'firebaseId';
const String kDbMEMBERSFIREBASEID = 'membersFirebaseId';
const String kDbMEMBERSDETAIL = 'membersDetail';
const String kDbCONVERSATIONID = 'conversationId';
const String kDbCONVERSATIONTYPE = 'conversationType';
const String kDbSOLO = 'solo';
const String kDbGroup = 'group';
const String kDbTHUMBNAIL = 'thumbnail';
const String kDbGROUPNAME = 'groupName';
const String kDbENCRYPTKEY = 'encryptKey';
const String kDbPERSONAL = 'personal';
const String kDbPERSONALRECEIVED = 'personalReceived';
const String kDbCONVERSATION = 'conversation';
const String kDbMUTED = 'muted';
const String kDbBLOCKED = 'blocked';
const String kDbBODYNOTIF = 'bodyNotif';
const String kDbISENABLENOTIF = 'isEnableNotif';
const String kDbPLATFORMID = 'platformId';
const String kDbIsPro = 'isPro';
const String kDbFavorite = 'favorite';
// const String kDb = '';
// const String kDb = '';
// const String kDb = ''; 

 