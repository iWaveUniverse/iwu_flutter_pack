import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AppUploader {
  static Future<String> uploadFile({
    required Uint8List data,
    required String path,
    required String userId,
    bool isNeedCompress = false,
    SettableMetadata? meta,
    Function(TaskSnapshot)? onUploading,
  }) async {
    // File name
    final storageRef = FirebaseStorage.instance;
    String assetName =
        '${userId}_${DateTime.now().millisecondsSinceEpoch.toString()}';

    if (isNeedCompress && (kIsWeb || Platform.isAndroid || Platform.isIOS)) {
      data = await FlutterImageCompress.compressWithList(data, minWidth: 600, minHeight: 600);
    }

    // Upload file
    final UploadTask uploadTask =
        storageRef.ref().child('$path/$userId/$assetName').putData(data, meta);
    if (onUploading != null) {
      uploadTask.snapshotEvents.listen(onUploading);
    }
    final TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }
}
