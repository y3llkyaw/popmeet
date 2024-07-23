import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class Functions {
  static Future<XFile?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    if (lastIndex == filePath.lastIndexOf(RegExp(r'.png'))) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
          filePath, outPath,
          minWidth: 1000,
          minHeight: 1000,
          quality: 50,
          format: CompressFormat.png);
      return compressedImage;
    } else {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
      );
      return compressedImage;
    }
  }

  static Future<String?> uploadPhoto(String imagePath, String location) async {
    try {
      final compressed = await Functions.compressImage(File(imagePath));
      imagePath = compressed!.path;
      final bytes = await File(imagePath).readAsBytes();
      final imgRef = FirebaseStorage.instance.ref().child(
          '${location}/${FirebaseAuth.instance.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imgRef.putData(bytes);
      final url = await imgRef.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }
}
