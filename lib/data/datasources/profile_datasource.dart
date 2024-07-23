import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:popmeet/core/constants/functions.dart';
import 'package:popmeet/data/datasources/firebase_auth_datasource.dart';
import 'package:popmeet/data/models/profile_model.dart';
import 'package:popmeet/domain/entities/profile.dart';

class ProfileDatasource {
  CollectionReference profiles =
      FirebaseFirestore.instance.collection('profiles');
  Future<Profile> createProfile(Profile profileData) async {
    final String? photoUrl = await uploadAvatar(profileData.photoPath);
    if (photoUrl == null) {
      throw Exception('Failed to upload photo');
    }
    Profile profile = Profile(
      id: profileData.id,
      email: profileData.email,
      name: profileData.name,
      photoPath: photoUrl,
      bio: profileData.bio,
      gender: profileData.gender,
    );

    // Add a new user to the "profiles" collection
    // Becarful Add [photoUrl] to [Profile] documents
    await profiles.doc(profile.id).set({
      'uid': profile.id,
      'displayName': profile.name,
      'email': profile.email,
      'bio': profile.bio,
      'gender': profile.gender.toString(),
      'photoURL': photoUrl,
    });
    await FirebaseAuthDataSource.updateDisplayName(profile.name);
    return profile;
  }

  Future<void> updateDisplayName(String name) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    await profiles.doc(FirebaseAuth.instance.currentUser?.uid).update({
      'displayName': name,
    });
  }

  Future<void> updateBio(String bio) async {
    await profiles.doc(FirebaseAuth.instance.currentUser?.uid).update({
      'bio': bio,
    });
  }

  Future<String?> uploadAvatar(String imagePath) async {
    try {
      final compressed = await Functions.compressImage(File(imagePath));
      final bytes = await File(compressed!.path).readAsBytes();
      final imgRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${FirebaseAuth.instance.currentUser?.uid}.jpg');
      await imgRef.putData(bytes);
      final url = await imgRef.getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  static Future<ProfileModel?> getProfileById(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('profiles').doc(uid).get();
    if (doc.exists) {
      return ProfileModel.fromFirebaseDatabase(doc);
    }
    return null;
  }

  static Future<List<ProfileModel>?> getAllProfiles() async {
    CollectionReference profiles =
        FirebaseFirestore.instance.collection('profiles');

    QuerySnapshot querySnapshot = await profiles.get();
    if (querySnapshot.docs.isNotEmpty) {
      if (querySnapshot.docs.isNotEmpty) {
        List<ProfileModel> profileModels = querySnapshot.docs.map((snapshot) {
          return ProfileModel.fromMap(snapshot);
        }).toList();
        return profileModels;
      }
    }
    return null;
  }

  static Stream<List<ProfileModel>?> getAllPeople() {
    print("get all people");
    return FirebaseFirestore.instance
        .collection("profiles")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return ProfileModel.fromMap(snapshot);
      }).toList();
    });
  }
}
