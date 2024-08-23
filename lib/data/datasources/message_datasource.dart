import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/data/models/message_model.dart';
import 'package:popmeet/domain/entities/profile.dart';

class MessageDatasource {
  CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  static Stream<List<MessageModel>?>? getMessage(String chatRoomId) {
    try {
      final messages = FirebaseFirestore.instance
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .where("chatRoomId", isEqualTo: chatRoomId)
          .snapshots()
          .map((snapshot) {
        final messagesModels = snapshot.docs.map((snapshot) {
          final messages = MessageModel.fromMap(snapshot);
          return messages;
        }).toList();
        return messagesModels;
      });

      return messages;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  static Stream<List<MessageModel>?>? getUserMessage() {
    try {
      final messages = FirebaseFirestore.instance
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .where("participants",
              arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .snapshots()
          .map((snapshot) {
        final messagesModels = snapshot.docs.map((snapshot) {
          final messages = MessageModel.fromMap(snapshot);
          return messages;
        }).toList();

        return messagesModels;
      });
      return messages;
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }

  static Future<void> addMessage(
      List<String> chatRoomId, String message) async {
    if (message.isNotEmpty) {
      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');
      chatRoomId.sort();
      final chatRoom = chatRoomId.join('_');

      DocumentReference docRef = await messages.add({
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'chatRoomId': chatRoom,
        'text': message,
        'participants': chatRoomId,
        'readParticipants': [FirebaseAuth.instance.currentUser?.uid],
        'createdAt': Timestamp.now(),
      });

      await docRef.update({'messageId': docRef.id});
    }
  }

  static Stream<List<Profile>> getInteractedProfiles() {
    return getUserMessage()!.asyncExpand((messages) async* {
      Set<String> profileIds = {};
      for (var message in messages!) {
        for (var participant in message.participants) {
          if (participant != FirebaseAuth.instance.currentUser?.uid) {
            profileIds.add(participant);
          }
        }
      }
      List<Profile> profiles = [];
      for (var profileId in profileIds) {
        final profile = await ProfileDatasource.getProfileById(profileId);
        if (profile != null) {
          profiles.add(profile);
        }
      }
      yield profiles;
    });
  }

  static Future<void> updateReadParticipants(
      String messageId, List<dynamic> readParticipants) async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      readParticipants.add(FirebaseAuth.instance.currentUser?.uid);
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .update({
        'readParticipants': readParticipants,
      });
    }
  }
}
