import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    required super.gender,
    required super.photoPath,
    required super.bio,
  });

  factory ProfileModel.fromFirebaseDatabase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
        id: doc.id,
        email: data['email'],
        name: data['displayName'],
        gender: Genders.values
            .firstWhere((element) => element.toString() == data['gender']),
        photoPath: data['photoURL'],
        bio: data['bio']);
  }
}
