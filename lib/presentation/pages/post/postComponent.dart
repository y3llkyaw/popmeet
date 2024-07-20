import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/domain/entities/post.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/presentation/pages/home/profile_page.dart';
import 'package:popmeet/presentation/pages/post/postDetail.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostComponent extends StatelessWidget {
  final Post post;
  const PostComponent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    Profile? profile;
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
                    future: ProfileDatasource.getProfileById(post.userId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        profile = snapshot.data;
                        return Row(
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    profile!.photoPath),
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
                                                title:
                                                    Text(profile!.name),
                                              ),
                                              body: ProfilePage(
                                                uid: profile!.id,
                                              ),
                                            )));
                                  },
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              timeago
                                  .format(post.create_at.toDate(),
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
                        MaterialPageRoute(
                            builder: (context) =>
                                PostDetail(post: post, profile: profile)));
                  },
                  child: Hero(
                    tag: post,
                    child: Container(
                      height: (MediaQuery.of(context).size.height / 2) - 20,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                post.photoURL,
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
                    post.content,
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
                  IconButton(
                      onPressed: () {}, icon: const Icon(CupertinoIcons.heart)),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.conversation_bubble)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(CupertinoIcons.share)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
