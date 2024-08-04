import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/domain/repositories/profile_repository.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _profileDataSource;

  ProfileRepositoryImpl({required ProfileDatasource profileDataSource})
      : _profileDataSource = profileDataSource;

  @override
  Future<Profile?> createProfile(Profile profile) {
    return _profileDataSource.createProfile(profile);
  }

  @override
  Future<void> updateDisplayName(String name) {
    return _profileDataSource.updateDisplayName(name);
  }

  @override
  Future<void> updateBio(String name) {
    return _profileDataSource.updateBio(name);
  }

  @override
  Future<String?> updateAvatar(String imagePath) {
    return _profileDataSource.updateAvatar(imagePath);
  }
}
