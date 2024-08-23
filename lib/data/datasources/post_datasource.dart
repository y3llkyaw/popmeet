import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:popmeet/core/constants/functions.dart';
import 'package:popmeet/data/models/comment_model.dart';
import 'package:popmeet/data/models/post_model.dart';
import 'package:popmeet/domain/entities/comment.dart';
import 'package:popmeet/domain/entities/post.dart';

class PostDatasource {
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  Future<Post> createPost(Post postData) async {
    final String? photoUrl =
        await Functions.uploadPhoto(postData.photoURL, "posts");
    if (photoUrl == null) {
      throw Exception('Failed to upload photo');
    }
    Post post = Post(
      postId: postData.postId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      photoURL: photoUrl,
      likes: postData.likes,
      content: postData.content,
      create_at: postData.create_at,
    );

    // Add a new [Post] to the "posts" collection
    // Becarful Add [photoUrl] to [Post] documents
    DocumentReference docRef = await posts.add({
      'uid': post.userId,
      'content': post.content,
      'photoURL': post.photoURL,
      'likes': post.likes,
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
    if (photoUrl != null) {
      final photoRef = FirebaseStorage.instance.refFromURL(photoUrl);
      await photoRef.delete();
    }
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    await posts.doc(post.postId.toString()).delete();
  }

  static Future<void> likePost(Post post) async {
    if (post.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      post.likes.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      post.likes.add(FirebaseAuth.instance.currentUser!.uid);
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId.toString())
        .update({'likes': post.likes});
    print(post.likes);
  }

  static Stream<PostModel?> getPostById(Post post) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId.toString())
        .snapshots()
        .map(
            (snapshot) => snapshot.exists ? PostModel.fromMap(snapshot) : null);
  }

  static commentPost(String comment, Post post) async {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId.toString())
        .collection('comments')
        .add({
      'likes': [],
      'comment': comment,
      'timestamp': DateTime.now(),
      'uid': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  static Stream<List<CommentModel>?> getComments(Post post) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId.toString())
        .collection("comments")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return CommentModel.fromMap(snapshot);
      }).toList();
    });
  }
}
