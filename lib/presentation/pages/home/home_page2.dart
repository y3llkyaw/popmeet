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
          key: const PageStorageKey("homepage2"),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              shadowColor: Colors.white,
              surfaceTintColor: Colors.white,
              floating: true,
              centerTitle: false,
              title: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "POP MEET",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: "Search",
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  icon: const Icon(Icons.camera),
                  tooltip: "Create Post",
                  onPressed: () async {
                    var image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                  value: postBloc,
                                  child: AddPost(imagePath: image.path))));
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
                ),
                IconButton(
                    tooltip: "Notifications",
                    onPressed: () {},
                    icon: const Icon(Icons.notifications)),
              ],
            ),
            BlocBuilder<PostBloc, PostState>(
              bloc: postBloc,
              builder: (context, state) {
                if (state is PostLoadedSuccess) {
                  List<Post>? posts = state.posts;
                  return SliverList.builder(
                      key: const PageStorageKey("homepage"),
                      itemCount: state.posts?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (posts == null) {
                          return const Center(
                              child: Text('No post have to show here'));
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
