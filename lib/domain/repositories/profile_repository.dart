import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> createProfile(Profile profile);

  Future<void> updateDisplayName(String name);

  Future<void> updateBio(String name);

  Future<String?> updateAvatar(String imagePath);
}
