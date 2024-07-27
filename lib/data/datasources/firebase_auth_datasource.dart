import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth auth;

  FirebaseAuthDataSource(this.auth);

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    final result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    final firebaseUser = result.user;
    if (firebaseUser != null) {
      return UserModel.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final firebaseUser = result.user;

    if (firebaseUser != null) {
      return UserModel.fromFirebaseUser(firebaseUser);
    }
    return null;
  }

  Future<void> signOut() async {
    await ProfileDatasource.isUserOnline(false);
    await auth.signOut();
  }

  static Future<UserModel?> updateDisplayName(String displayName) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser!;
    await user.updateDisplayName(displayName);
    await auth.currentUser?.reload();
    user = auth.currentUser!;
    return UserModel.fromFirebaseUser(user);
  }
}
