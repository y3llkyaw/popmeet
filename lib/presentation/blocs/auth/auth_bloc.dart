import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:popmeet/domain/entities/user.dart';
import 'package:popmeet/domain/usecases/auth/register_usecase.dart';
import 'package:popmeet/domain/usecases/auth/sigin_usecase.dart';
import 'package:popmeet/domain/usecases/auth/signout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUsecase;
  final SignoutUsecase signOutUseCase;

  AuthBloc(this.signInUseCase, this.registerUsecase, this.signOutUseCase)
      : super(AuthInitial()) {
    on<AuthRequestEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInUseCase.call(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(const AuthFailure('Invalid email or password'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await registerUsecase.call(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(const AuthFailure('Invalid email or password'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignoutEvent>((event, emit) async {
      signOutUseCase.call();
    });
  }
}
