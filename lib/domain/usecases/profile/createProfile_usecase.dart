import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/domain/repositories/profile_repository.dart';
import '../../entities/user.dart';

class CreateprofileUsecase {
  final ProfileRepository repository;

  CreateprofileUsecase(this.repository);

  Future<User?> call(Profile profile) {
    return repository.createProfile(profile);
  }
}
