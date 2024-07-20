import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/repositories/post_repository.dart';

class CreatePostUsecase {
  final PostRepository repository;
  CreatePostUsecase({required this.repository});

  Future<void> call(Post post) async {
    await repository.createPost(post);
  }
}
