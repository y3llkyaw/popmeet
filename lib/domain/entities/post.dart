import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? postId;
  final String userId;
  final String photoURL;
  final String content;
  final Timestamp create_at;

  Post(
      {this.postId,
      required this.userId,
      required this.photoURL,
      required this.content,
      required this.create_at});

  Post copyWith({
    String? userId,
    String? photoURL,
    String? content,
    DateTime? create_at,
    String? postId,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      photoURL: photoURL ?? this.photoURL,
      content: content ?? this.content,
      create_at: this.create_at,
    );
  }
}
