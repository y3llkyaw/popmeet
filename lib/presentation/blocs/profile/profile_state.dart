part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  const ProfileLoaded({required this.profile});
}

final class ProfileSuccess extends ProfileState {}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
}

final class ProfileUpdating extends ProfileState {}

final class ProfileUpdateSuccess extends ProfileState {}

final class ProfilesLoaded extends ProfileState {
  ProfileModel userProfile;
  List<Profile> profiles;
  ProfilesLoaded({required this.profiles, required this.userProfile});
}
