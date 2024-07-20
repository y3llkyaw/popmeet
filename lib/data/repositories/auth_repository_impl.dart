import 'package:popmeet/data/datasources/firebase_auth_datasource.dart';
import 'package:popmeet/domain/entities/user.dart';
import 'package:popmeet/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;

  AuthRepositoryImpl(this._firebaseAuthDataSource);

  @override
  Future<User?> registerWithEmailAndPassword(String email, String password) {
    return _firebaseAuthDataSource.registerWithEmailAndPassword(
        email, password);
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuthDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuthDataSource.signOut();
  }
}
