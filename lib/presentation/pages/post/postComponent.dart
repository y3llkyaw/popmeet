import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:popmeet/data/datasources/post_datasource.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/data/models/comment_model.dart';
import 'package:popmeet/data/models/post_model.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/presentation/pages/home/profile_page.dart';
import 'package:popmeet/presentation/pages/post/postDetail.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostComponent extends StatefulWidget {
  final Post post;
  final bool? showDetail;

  const PostComponent({super.key, required this.post, this.showDetail});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  bool isLiked = false;
  bool isCommenting = false;
  TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Profile? profile;
    bool showDetail = false;
    if (widget.showDetail == true) {
      showDetail = true;
      isCommenting = true;
    }
    if (widget.post.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      isLiked = true;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(4, 8),
          ),
        ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.grey.shade300),
                child: FutureBuilder(
                    future:
                        ProfileDatasource.getProfileById(widget.post.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        profile = snapshot.data;
                        return Row(
                          children: [
                            SizedBox(
                              height: showDetail ? 50 : 30,
                              width: showDetail ? 50 : 30,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  title: Text(
                                                      "${profile!.name}'s Profile"),
                                                ),
                                                body: ProfilePage(
                                                  profile: profile!,
                                                ),
                                              )));
                                },
                                child: Hero(
                                  tag: profile!,
                                  child: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        profile!.photoPath),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                text: profile!.name,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: Text(
                                                        "${profile!.name}'s Profile"),
                                                  ),
                                                  body: ProfilePage(
                                                    profile: profile!,
                                                  ),
                                                )));
                                  },
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: showDetail ? 15 : 13,
                                    color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              timeago
                                  .format(widget.post.create_at.toDate(),
                                      allowFromNow: true)
                                  .toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        );
                      } else {
                        return const Row(
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        );
                      }
                    })),
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PostDetail(
                          post: widget.post,
                          profile: profile,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                        transitionDuration: const Duration(
                            milliseconds:
                                800), // Set your desired duration here
                      ),
                    );
                  },
                  child: Hero(
                    tag: widget.post,
                    child: Container(
                      height: (MediaQuery.of(context).size.height / 2) - 20,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                widget.post.photoURL,
                                errorListener: (p0) {
                                  print(p0);
                                },
                              ))),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(103, 0, 0, 0),
                  ),
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    widget.post.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              height: 35,
              decoration: BoxDecoration(color: Colors.grey.shade300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                          onPressed: () async {
                            setState(() {
                              if (!isLiked) {
                                isLiked = true;
                              } else {
                                isLiked = false;
                              }
                            });
                            await PostDatasource.likePost(widget.post);
                          },
                          icon: isLiked
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.pink,
                                )
                              : const Icon(CupertinoIcons.heart)),
                      InkWell(
                        onTap: () {
                          print("likes counts");
                        },
                        child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.pinkAccent,
                            child: StreamBuilder<PostModel?>(
                                stream: PostDatasource.getPostById(widget.post),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data?.likes.length.toString() ??
                                        '0',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  );
                                })),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (!isCommenting) {
                            isCommenting = true;
                          } else {
                            isCommenting = false;
                          }
                        });
                      },
                      icon: Icon(
                        isCommenting
                            ? CupertinoIcons.chat_bubble_fill
                            : CupertinoIcons.chat_bubble,
                        color: isCommenting ? Colors.green : Colors.black,
                      )),
                  IconButton(
                      onPressed: () {}, icon: const Icon(CupertinoIcons.share)),
                ],
              ),
            ),
            Visibility(
              visible: isCommenting,
              child: Column(children: [
                Container(
                  color: Colors.grey.shade300,
                  child: StreamBuilder<List<CommentModel>?>(
                      stream: PostDatasource.getComments(widget.post),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              for (var comment in snapshot.data!)
                                FutureBuilder(
                                    future: ProfileDatasource.getProfileById(
                                        comment.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    snapshot.data!.photoPath),
                                          ),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(snapshot.data!.name),
                                              Text(
                                                timeago
                                                    .format(
                                                        comment.timestamp
                                                            .toDate(),
                                                        allowFromNow: true)
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(comment.comment),
                                        );
                                      }
                                      return Container();
                                    })
                            ],
                          );
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                        }

                        return Container();
                      }),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        border: InputBorder.none,
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await PostDatasource.commentPost(
                            commentController.text, widget.post);
                        commentController.clear();
                      },
                      icon: const Icon(CupertinoIcons.paperplane))
                ]),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
