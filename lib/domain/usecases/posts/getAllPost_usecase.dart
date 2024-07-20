import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/repositories/post_repository.dart';

class GetallpostUsecase {
  final PostRepository repository;

  const GetallpostUsecase({required this.repository});

  Future<List<Post>?> call() {
    return repository.getAllPosts();
  }
}
