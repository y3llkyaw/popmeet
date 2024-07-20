import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popmeet/data/models/post_model.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:path/path.dart' as p;

class PostDatasource {
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Future<Post> createPost(Post postData) async {
    final String? photoUrl = await uploadPostPhoto(postData.photoURL);
    if (photoUrl == null) {
      throw Exception('Failed to upload photo');
    }
    Post post = Post(
      postId: postData.postId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      photoURL: photoUrl,
      content: postData.content,
      create_at: postData.create_at,
    );

    // Add a new [Post] to the "posts" collection
    // Becarful Add [photoUrl] to [Post] documents
    DocumentReference docRef = await posts.add({
      'uid': post.userId,
      'content': post.content,
      'photoURL': post.photoURL,
      'created_at': post.create_at,
    });
    post = post.copyWith(postId: docRef.id);
    await docRef.update({'postId': post.postId});
    return post;
  }

  Future<List<PostModel>?> getPostsByUid(String uid) async {
    QuerySnapshot querySnapshot = await posts
        .where('uid', isEqualTo: uid.toString())
        .orderBy('created_at', descending: true)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List<PostModel> postModels = querySnapshot.docs.map((snapshot) {
        return PostModel.fromMap(snapshot);
      }).toList();
      return postModels;
    }
    return null;
  }

  Future<List<PostModel>?> getAllPosts() async {
    QuerySnapshot querySnapshot =
        await posts.orderBy('created_at', descending: true).get();
    if (querySnapshot.docs.isNotEmpty) {
      List<PostModel> postModels = querySnapshot.docs.map((snapshot) {
        return PostModel.fromMap(snapshot);
      }).toList();
      return postModels;
    }
    return null;
  }

  static Future<void> deletePost(Post post) async {
    final String? photoUrl = post.photoURL;
    print(post.postId);
    if (photoUrl != null) {
      final photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
      await photoRef.delete();
    }
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    await posts.doc(post.postId.toString()).delete();
  }

  Future<String?> uploadPostPhoto(String imagePath) async {
    try {
      final compressed = await compressImage(File(imagePath));
      imagePath = compressed!.path;
      final bytes = await File(imagePath).readAsBytes();
      final imgRef = FirebaseStorage.instance.ref().child(
          'posts/${FirebaseAuth.instance.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imgRef.putData(bytes);
      final url = await imgRef.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  Future<XFile?> compressImage(File file) async {
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
}
