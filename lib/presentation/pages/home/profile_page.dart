import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/chat/chat_page.dart';
import 'package:popmeet/presentation/pages/home/setting_page.dart';
import 'package:popmeet/presentation/pages/post/addPost.dart';
import 'package:popmeet/presentation/pages/post/postDetail.dart';
import 'package:shimmer_effect/shimmer_effect.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;

  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    final postBloc = BlocProvider.of<PostBloc>(context);

    if (postBloc.state is PostLoadedSuccess) {
      if ((postBloc.state as PostLoadedSuccess).profilePost?.first.userId !=
          profile.id) {
        postBloc.add(GetPostsEvent(uid: profile.id));
      } else if ((postBloc.state as PostLoadedSuccess).profilePost == null) {}
    } else {
      postBloc.add(GetPostsEvent(uid: profile.id));
    }

    if (profileBloc.state is ProfilesLoaded) {
    } else {
      profileBloc.add(GetAllProfilesEvent(profile.id));
    }

    pickImage(XFile image) {
      showDialog(
          context: context,
          builder: (context) {
            return BlocListener<ProfileBloc, ProfileState>(
              bloc: profileBloc,
              listener: (context, state) {
                if (state is ProfileUpdating) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                            // child: CircularProgressIndicator(),
                            );
                      });
                } else if (state is ProfileUpdateSuccess) {
                  Navigator.pop(context);
                  profileBloc.add(GetAllProfilesEvent(profile.id));
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 300,
                        width: 300,
                        child: CircleAvatar(
                          backgroundImage: FileImage(File(image.path)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Your Profile Picture will be look like it",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 200,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              profileBloc
                                  .add(UpdateAvatarEvent(image: image.path));
                            },
                            child: const Text('Accept')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Discard'))
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      body: BlocListener<PostBloc, PostState>(
        bloc: postBloc,
        listener: (context, state) {
          if (state is PostSuccess) {
            postBloc.add(GetPostsEvent(uid: profile.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Builder(builder: (context) {
                        return SizedBox(
                            width: mediaQuery.width * 0.25,
                            height: mediaQuery.width * 0.25,
                            child: InkWell(
                              onTap: () async {
                                if (profile.id ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  var image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    pickImage(image);
                                  }
                                }
                              },
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: SizedBox(
                                          height: 400,
                                          width: 400,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              profileBloc.state
                                                      is ProfileSuccess
                                                  ? (profileBloc.state
                                                          as ProfilesLoaded)
                                                      .userProfile
                                                      .photoPath
                                                  : profile.photoPath,
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Hero(
                                tag: profile,
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    profileBloc.state is ProfileSuccess
                                        ? (profileBloc.state as ProfilesLoaded)
                                            .userProfile
                                            .photoPath
                                        : profile.photoPath,
                                  ),
                                ),
                              ),
                            ));
                      }),
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
                          } else if (state is ProfilesLoaded) {
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
                                            profile.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                            maxLines: 3,
                                          ),
                                        ),
                                        Icon(
                                          profile.gender == Genders.male
                                              ? Icons.male
                                              : profile.gender == Genders.female
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
                                            profile.bio ?? '',
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
                                            profile.id ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid
                                                ? IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const SettingPage()));
                                                    },
                                                    icon: const Icon(
                                                        CupertinoIcons
                                                            .settings))
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
                  profile.id != FirebaseAuth.instance.currentUser!.uid
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    iconColor: Colors.black,
                                    textStyle: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 156, 67, 67)),
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder()),
                                label: const Text(
                                  'follow',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {},
                                icon: const Icon(
                                    CupertinoIcons.plus_rectangle_fill)),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    iconColor: Colors.black,
                                    textStyle:
                                        const TextStyle(color: Colors.black),
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder()),
                                label: const Text(
                                  'chat ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                                profile: profile,
                                              )));
                                },
                                icon: const Icon(CupertinoIcons.chat_bubble)),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_horiz)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    iconColor: Colors.black,
                                    textStyle:
                                        const TextStyle(color: Colors.black),
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder()),
                                label: const Text(
                                  'create post',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  var image = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BlocProvider.value(
                                                    value: postBloc,
                                                    child: AddPost(
                                                        imagePath:
                                                            image.path))));
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
                                icon: const Icon(
                                    CupertinoIcons.camera_on_rectangle)),
                            const SizedBox(
                              width: 10,
                            ),
                            // ElevatedButton.icon(
                            //     style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.grey.shade200,
                            //         iconColor: Colors.black,
                            //         textStyle: const TextStyle(
                            //             color: Colors.black),
                            //         elevation: 0,
                            //         shape: const RoundedRectangleBorder()),
                            //     label: const Text(
                            //       'chat ',
                            //       style: TextStyle(
                            //           fontWeight: FontWeight.bold),
                            //     ),
                            //     onPressed: () {},
                            //     icon:
                            //         const Icon(CupertinoIcons.chat_bubble)),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_horiz)),
                          ],
                        ),
                ],
              ),
              Expanded(
                child: Container(
                  width: mediaQuery.width * 0.9,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  child: BlocBuilder<PostBloc, PostState>(
                    bloc: postBloc,
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return ShimmerEffect(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white24,
                            child: GridView.builder(
                                itemCount: 30,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      3, // number of items in each row
                                  mainAxisSpacing: 7.0, // spacing between rows
                                  crossAxisSpacing:
                                      7.0, // spacing between columns
                                ),
                                itemBuilder: (context, index) {
                                  return Container();
                                }));
                      } else if (state is PostLoadedSuccess) {
                        if (state.profilePost == null) {
                          return const Center(child: Text('No Posts'));
                        }
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
                                            image: NetworkImage(state
                                                    .profilePost?[index]
                                                    .photoURL ??
                                                ''))), // color of grid items
                                  ),
                                ),
                              );
                            });
                      } else {
                        return const Text('No Posts');
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
