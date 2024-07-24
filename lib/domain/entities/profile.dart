import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/domain/entities/user.dart';

class Profile extends User {
  String name;
  String photoPath;
  String? bio;
  Genders gender;
  bool isOnline;

  Profile({
    required super.id,
    required super.email,
    required this.name,
    required this.photoPath,
    required this.bio,
    required this.gender,
    required this.isOnline,
  });
}
