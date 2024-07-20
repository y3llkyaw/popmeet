import 'package:popmeet/domain/entities/post.dart';

abstract class PostRepository {
  Future<Post?> createPost(Post post);

  Future<List<Post>?> getPostsByUid(String uid);

  Future<List<Post>?> getAllPosts();
}
