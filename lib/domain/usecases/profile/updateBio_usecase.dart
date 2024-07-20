import 'package:popmeet/domain/repositories/profile_repository.dart';

class UpdatebioUsecase {
  final ProfileRepository repository;
  UpdatebioUsecase(this.repository);

  Future<void> call(String bio) {
    return repository.updateBio(bio);
  }
}
