import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/pages/post/addPost.dart';
import 'package:popmeet/presentation/pages/post/postComponent.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              shadowColor: Colors.white,
              surfaceTintColor: Colors.white,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        "POP Meet",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: "Search",
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                        ),
                        IconButton(
                          onPressed: () async {
                            var image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (image != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                          value: postBloc,
                                          child:
                                              AddPost(imagePath: image.path))));
                            } else {
                              Fluttertoast.showToast(
                                msg: "No Image Selected",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.SNACKBAR,
                                backgroundColor: Colors.grey,
                                textColor: Colors.black,
                                fontSize: 16.0,
                              );
                            }
                          },
                          icon: const Icon(Icons.camera),
                          tooltip: "Create Post",
                        ),
                        IconButton(
                            tooltip: "Notifications",
                            onPressed: () {},
                            icon: const Icon(Icons.notifications))
                      ],
                    )
                  ],
                ),
              ),
            ),
            BlocBuilder<PostBloc, PostState>(
              bloc: postBloc,
              builder: (context, state) {
                if (state is PostLoadedSuccess) {
                  List<Post>? posts = state.posts;
                  return SliverList.builder(
                      itemCount: state.posts?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (posts == null) {
                          return Container(
                            child: const Text('No post have to show here'),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PostComponent(
                              post: posts[index],
                            ),
                          );
                        }
                      });
                } else {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
