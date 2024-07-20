import 'package:popmeet/domain/repositories/profile_repository.dart';

class UpdatedisplaynameUsecase {
  final ProfileRepository repository;

  UpdatedisplaynameUsecase(this.repository);

  Future<void> call(String name) {
    return repository.updateDisplayName(name);
  }
}
