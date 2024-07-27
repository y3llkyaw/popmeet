import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popmeet/data/models/message_model.dart';

class MessageDatasource {
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  static Stream<List<MessageModel>?>? getMessage(String chatRoomId) {
    try {
      print(chatRoomId);
      final messages = FirebaseFirestore.instance
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .where("chatRoomId", isEqualTo: chatRoomId)
          .snapshots()
          .map((snapshot) {
        final messagesModels = snapshot.docs.map((snapshot) {
          final messages = MessageModel.fromMap(snapshot);
          print(messages);
          return messages;
        }).toList();
        print(messagesModels);
        return messagesModels;
      });
      print(messages);
      return messages;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  static Future<void> addMessage(
      List<String> chatRoomId, String message) async {
    if (!message.isEmpty) {
      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');
      chatRoomId.sort();
      final chatRoom = chatRoomId.join('_');

      DocumentReference docRef = await messages.add({
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'chatRoomId': chatRoom,
        'text': message,
        'createdAt': Timestamp.now(),
      });

      await docRef.update({'messageId': docRef.id});
    }
  }
}
