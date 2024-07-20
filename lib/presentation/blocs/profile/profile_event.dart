part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class CreateProfileEvent extends ProfileEvent {
  final String name;
  final String bio;
  final Genders gender;
  final String photoURL;

  const CreateProfileEvent(
      {required this.name,
      required this.bio,
      required this.gender,
      required this.photoURL});
}

class UpdateDisplayNameEvent extends ProfileEvent {
  final String name;
  const UpdateDisplayNameEvent({required this.name});
}

class UpdateBioEvent extends ProfileEvent {
  final String bio;
  const UpdateBioEvent({required this.bio});
}

class GetProfileEvent extends ProfileEvent {
  final String uid;
  const GetProfileEvent({required this.uid});
}
