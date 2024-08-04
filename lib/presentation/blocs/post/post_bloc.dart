import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:popmeet/data/datasources/post_datasource.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/usecases/posts/createPost_usecase.dart';
import 'package:popmeet/domain/usecases/posts/getAllPost_usecase.dart';
import 'package:popmeet/domain/usecases/posts/getPostsByUid_usecase.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final CreatePostUsecase _createPostUsecase;
  final GetpostsbyuidUsecase _getpostsbyuidUsecase;
  final GetallpostUsecase _getallpostUsecase;

  PostBloc(this._createPostUsecase, this._getpostsbyuidUsecase,
      this._getallpostUsecase)
      : super(PostInitial()) {
    on<PostCreateEvent>((event, emit) async {
      emit(PostLoading());
      try {
        Post post = Post(
          userId: FirebaseAuth.instance.currentUser!.uid,
          content: event.content,
          photoURL: event.photoURL,
          create_at: Timestamp.now(),
        );
        await _createPostUsecase.call(post);
        emit(PostSuccess());
      } catch (e) {
        emit(PostFailure(message: e.toString()));
      }
    });

    on<GetPostsEvent>((event, emit) async {
      emit(PostLoading());
      try {
        final profilePosts = await _getpostsbyuidUsecase.call(event.uid);
        final allPosts = await _getallpostUsecase.call();
        print(profilePosts);
        emit(PostLoadedSuccess(profilePost: profilePosts, posts: allPosts));
      } catch (e) {
        print(e.toString());
        emit(PostFailure(message: e.toString()));
      }
    });

    on<DeletePostEvent>((event, emit) async {
      emit(PostLoading());
      try {
        await PostDatasource.deletePost(event.post);
        emit(PostDeleted());
      } catch (e) {
        print(e.toString());
        emit(PostFailure(message: e.toString()));
      }
    });
  }
}
