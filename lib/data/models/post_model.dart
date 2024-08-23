import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popmeet/domain/entities/post.dart';

class PostModel extends Post {
  PostModel(
      {required super.userId,
      required super.photoURL,
      required super.content,
      required super.likes,
      required super.create_at,
      required super.postId});

  factory PostModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id,
      userId: map['uid'],
      photoURL: map['photoURL'],
      likes: map['likes'],
      content: map['content'],
      create_at: map['created_at'],
    );
  }
}
