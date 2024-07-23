import 'package:popmeet/domain/repositories/profile_repository.dart';

class UpdateAvatarUsecase {
  final ProfileRepository repository;
  UpdateAvatarUsecase({required this.repository});
  Future<String?> call(String bio) {
    return repository.updateAvatar(bio);
  }
}
