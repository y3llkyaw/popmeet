import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String chatRoomId;
  final String text;
  final Timestamp createdAt;

  Message(
      {required this.messageId,
      required this.senderId,
      required this.chatRoomId,
      required this.text,
      required this.createdAt});
}
