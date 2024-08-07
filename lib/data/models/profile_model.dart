import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.lastOnline,
    required super.id,
    required super.email,
    required super.name,
    required super.gender,
    required super.photoPath,
    required super.bio,
    required super.isOnline,
  });

  factory ProfileModel.fromFirebaseDatabase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
        lastOnline: data['lastOnline'],
        id: doc.id,
        email: data['email'],
        name: data['displayName'],
        gender: Genders.values
            .firstWhere((element) => element.toString() == data['gender']),
        photoPath: data['photoURL'],
        isOnline: data['isOnline'],
        bio: data['bio']);
  }

  factory ProfileModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      lastOnline: map['lastOnline'],
      id: doc.id,
      email: map['email'],
      name: map['displayName'],
      gender: Genders.values
          .firstWhere((element) => element.toString() == map['gender']),
      photoPath: map['photoURL'],
      isOnline: map['isOnline'],
      bio: map['bio'],
    );
  }
}
