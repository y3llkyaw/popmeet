import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/pages/post/postComponent.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final postBloc = BlocProvider.of<PostBloc>(context);
    if (postBloc.state is PostLoadedSuccess) {
      if ((postBloc.state as PostLoadedSuccess).posts == null) {
        postBloc
            .add(GetPostsEvent(uid: FirebaseAuth.instance.currentUser!.uid));
      }
    } else {
      postBloc.add(GetPostsEvent(uid: FirebaseAuth.instance.currentUser!.uid));
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          postBloc
              .add(GetPostsEvent(uid: FirebaseAuth.instance.currentUser!.uid));
          return Future.delayed(const Duration(milliseconds: 100));
        },
        child: BlocBuilder<PostBloc, PostState>(
          bloc: postBloc,
          builder: (context, state) {
            if (state is PostLoadedSuccess) {
              List<Post>? posts = state.posts;

              if (posts == null) {
                return const Center(child: Text('No post have to show yet!'));
              }
              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: state.posts?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (posts == null) {
                      return Container(
                        child: Text('No post have to show here'),
                      );
                    } else {
                      return PostComponent(
                        post: posts[index],
                      );
                    }
                  });
            } else if (state is PostLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container();
          },
        ),
      ),
    );
  }
}
