// ignore_for_file: must_be_immutable

part of 'post_bloc.dart';

@immutable
class PostState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class PostInitial extends PostState {
  PostInitial();
}

final class PostLoading extends PostState {}

final class PostSuccess extends PostState {
  List<Post>? posts;
  List<Post>? profilePost;
  PostSuccess({this.posts, this.profilePost});

  @override
  List<Object?> get props => [posts, profilePost];
}

final class PostFailure extends PostState {
  final String message;
  PostFailure({required this.message});
}

final class PostDeleted extends PostState {}
