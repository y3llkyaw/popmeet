import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/repositories/post_repository.dart';

class GetpostsbyuidUsecase {
  final PostRepository repository;

  GetpostsbyuidUsecase({required this.repository});

  Future<List<Post>?> call(String uid) {
    return repository.getPostsByUid(uid);
  }
}
