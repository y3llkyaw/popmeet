import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popmeet/domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel(
      {required super.messageId,
      required super.senderId,
      required super.chatRoomId,
      required super.text,
      required super.createdAt});

  factory MessageModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    final message = MessageModel(
      messageId: map['messageId'],
      senderId: map['senderId'],
      chatRoomId: map['chatRoomId'],
      text: map['text'],
      createdAt: map['createdAt'],
    );

    return message;
  }
}
