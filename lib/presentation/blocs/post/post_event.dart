part of 'post_bloc.dart';

@immutable
sealed class PostEvent {}

class PostCreateEvent extends PostEvent {
  final String content;
  final String photoURL;
  PostCreateEvent({required this.content, required this.photoURL});
}

class DeletePostEvent extends PostEvent {
  final Post post;
  DeletePostEvent({required this.post});
}

class GetPostsEvent extends PostEvent {
  final String uid;
  GetPostsEvent({required this.uid});
}
