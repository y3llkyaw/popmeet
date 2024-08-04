import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/entities/profile.dart';

class PostDetail extends StatelessWidget {
  final Post post;
  final Profile? profile;
  const PostDetail({super.key, required this.post, required this.profile});

  @override
  Widget build(BuildContext context) {
    final postBloc = BlocProvider.of<PostBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Detail',
          style: TextStyle(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.grey.shade300),
              child: Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(profile!.photoPath),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    profile!.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(timeago
                      .format(post.create_at.toDate(), allowFromNow: true)
                      .toString()),
                  Builder(builder: (context) {
                    if (FirebaseAuth.instance.currentUser!.uid == post.userId) {
                      return IconButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return BlocListener<PostBloc, PostState>(
                                    bloc: postBloc,
                                    listener: (context, state) {
                                      if (state is PostDeleted) {
                                        Fluttertoast.showToast(
                                            msg: "Post Deleted !");
                                        postBloc.add(GetPostsEvent(
                                            uid: FirebaseAuth
                                                .instance.currentUser!.uid));
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text(
                                            "Are you sure you want to delete this post ?",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    BlocProvider.of<PostBloc>(
                                                            context)
                                                        .add(DeletePostEvent(
                                                            post: post));
                                                  },
                                                  child: const Text("Yes")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("No")),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                          ));
                    }
                    return Container();
                  })
                ],
              ),
            ),
            Hero(tag: post, child: CachedNetworkImage(imageUrl: post.photoURL)),
          ],
        ),
      ),
    );
  }
}
