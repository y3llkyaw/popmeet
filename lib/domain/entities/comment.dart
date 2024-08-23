import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String uid;
  final String comment;
  final List<dynamic> likes;
  final Timestamp timestamp;
  Comment(
      {required this.uid,
      required this.comment,
      required this.likes,
      required this.timestamp});
}
