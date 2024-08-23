import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popmeet/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel(
      {required super.uid,
      required super.comment,
      required super.likes,
      required super.timestamp});

  factory CommentModel.fromMap(DocumentSnapshot doc) {
    return CommentModel(
      uid: doc['uid'],
      comment: doc['comment'],
      likes: doc['likes'],
      timestamp: doc['timestamp'],
    );
  }
}
