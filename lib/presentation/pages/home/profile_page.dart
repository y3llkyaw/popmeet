import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/data/models/profile_model.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/home/setting_page.dart';
import 'package:popmeet/presentation/pages/post/postDetail.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    final postBloc = BlocProvider.of<PostBloc>(context);
    ProfileModel? profile;

    if (profileBloc.state is ProfileLoaded) {
      profile = (profileBloc.state as ProfileLoaded).profile;
      if (profile.id != uid) {
        profileBloc.add(GetProfileEvent(uid: uid));
      }
    } else {
      profileBloc.add(GetProfileEvent(uid: uid));
    }

    if (postBloc.state is PostSuccess) {
      if ((postBloc.state as PostSuccess).profilePost?.first.userId != uid) {
        postBloc.add(GetPostsEvent(uid: uid));
      } else if ((postBloc.state as PostSuccess).profilePost == null) {}
    } else {
      postBloc.add(GetPostsEvent(uid: uid));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return SizedBox(
                              width: mediaQuery.width * 0.25,
                              height: mediaQuery.width * 0.25,
                              child: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/avatar_b.png'),
                              ));
                        } else if (state is ProfileLoaded) {
                          profile = state.profile;
                          return SizedBox(
                              width: mediaQuery.width * 0.25,
                              height: mediaQuery.width * 0.25,
                              child: InkWell(
                                onTap: () async {
                                  var image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            color: Colors.black54,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    height: 300,
                                                    width: 300,
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          FileImage(
                                                              File(image.path)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const Text(
                                                  "Your Profile Picture will be look like it ?",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(
                                                  height: 200,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Accept')),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Discard'))
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 100,
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      state.profile.photoPath),
                                ),
                              ));
                        } else if (state is ProfileError) {
                          return CircleAvatar(
                            child: Text(state.message),
                          );
                        }
                        return Container();
                      },
                    ),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      bloc: profileBloc,
                      builder: (context, state) {
                        if (state is ProfileLoading) {
                          return Row(
                            children: [
                              Column(
                                children: [
                                  const Text('Profile is Loading'),
                                  SizedBox(
                                      width: mediaQuery.width * 0.5,
                                      child: const LinearProgressIndicator())
                                ],
                              ),
                            ],
                          );
                        } else if (state is ProfileLoaded) {
                          return Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          state.profile.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                          maxLines: 3,
                                        ),
                                      ),
                                      Icon(
                                        state.profile.gender == Genders.male
                                            ? Icons.male
                                            : state.profile.gender ==
                                                    Genders.female
                                                ? Icons.female
                                                : Icons.transgender,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 165,
                                        child: Text(
                                          state.profile.bio ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400),
                                          maxLines: 3,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12),
                                          ),
                                          uid ==
                                                  FirebaseAuth
                                                      .instance.currentUser?.uid
                                              ? IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const SettingPage()));
                                                  },
                                                  icon: const Icon(
                                                      CupertinoIcons.settings))
                                              : IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      CupertinoIcons
                                                          .person_badge_plus))
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (state is ProfileError) {
                          return Text(state.message);
                        }
                        return const Text('');
                      },
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Container(
                  width: mediaQuery.width * 0.9,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  height: mediaQuery.height * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  child: BlocBuilder<PostBloc, PostState>(
                    bloc: postBloc,
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      } else if (state is PostSuccess) {
                        return GridView.builder(
                            itemCount: state.profilePost?.length ?? 0,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // number of items in each row
                              mainAxisSpacing: 7.0, // spacing between rows
                              crossAxisSpacing: 7.0, // spacing between columns
                            ),
                            itemBuilder: (context, index) {
                              final post = state.profilePost![index];
                              return InkWell(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PostDetail(
                                                post: post,
                                                profile: profile,
                                              )))
                                },
                                child: Hero(
                                  tag: post,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                                state.profilePost?[index]
                                                        .photoURL ??
                                                    ''))), // color of grid items
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Text('Hello');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
