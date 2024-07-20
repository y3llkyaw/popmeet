import 'package:popmeet/data/datasources/post_datasource.dart';
import 'package:popmeet/data/models/post_model.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/repositories/post_repository.dart';

class PostRepositoryImpl extends PostRepository {
  PostDatasource _postDatasource;

  PostRepositoryImpl(this._postDatasource);

  Future<Post?> createPost(Post post) {
    return _postDatasource.createPost(post);
  }

  @override
  Future<List<PostModel>?> getPostsByUid(String uid) {
    return _postDatasource.getPostsByUid(uid);
  }

  @override
  Future<List<Post>?> getAllPosts() {
    return _postDatasource.getAllPosts();
  }
}
