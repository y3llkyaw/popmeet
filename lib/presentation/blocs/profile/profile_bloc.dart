import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/data/models/profile_model.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/domain/usecases/profile/createProfile_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateAvatar_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateBio_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateDisplayName_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CreateprofileUsecase _createprofileUsecase;
  final UpdatedisplaynameUsecase _updatedisplaynameUsecase;
  final UpdatebioUsecase _updatebioUsecase;
  final UpdateAvatarUsecase _updateavatarUsecase;

  ProfileBloc(this._createprofileUsecase, this._updatedisplaynameUsecase,
      this._updatebioUsecase, this._updateavatarUsecase)
      : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) async {
      print(event.toString());
    });
    on<CreateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      print('emmited loading');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final newProfile = Profile(
              isOnline: true,
              id: user.uid,
              email: user.email ?? '',
              name: event.name,
              photoPath: event.photoURL,
              bio: event.bio,
              gender: event.gender,
              lastOnline: Timestamp.now());
          _createprofileUsecase.call(newProfile);
        }
        emit(ProfileSuccess());
        print('emmited success');
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final p = await ProfileDatasource.getProfileById(event.uid);
        if (p != null) {
          emit(ProfileLoaded(profile: p));
        }
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<GetAllProfilesEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        print("get");
        final userProfile = await ProfileDatasource.getProfileById(event.uid);
        final profiles = await ProfileDatasource.getAllProfiles();
        if (userProfile != null && profiles != null) {
          emit(ProfilesLoaded(profiles: profiles, userProfile: userProfile));
        }
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateDisplayNameEvent>((event, emit) async {
      emit(ProfileUpdating());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _updatedisplaynameUsecase.call(event.name);
        }
        emit(ProfileUpdateSuccess());
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateBioEvent>((event, emit) async {
      emit(ProfileUpdating());
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _updatebioUsecase.call(event.bio);
        }
        emit(ProfileUpdateSuccess());
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateAvatarEvent>((event, emit) async {
      emit(ProfileUpdating());
      print("updating");
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _updateavatarUsecase.call(event.image);
        }
        emit(ProfileUpdateSuccess());
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
