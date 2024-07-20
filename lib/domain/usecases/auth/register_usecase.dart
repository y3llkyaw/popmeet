import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> call(String email, String password) {
    return repository.registerWithEmailAndPassword(email, password);
  }
}
