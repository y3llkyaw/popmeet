import '../../repositories/auth_repository.dart';

class SignoutUsecase {
  final AuthRepository repository;

  SignoutUsecase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
