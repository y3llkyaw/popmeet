import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/components/form_container.dart';

class AddPost extends StatefulWidget {
  var imagePath;

  AddPost({super.key, required this.imagePath});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postBloc = BlocProvider.of<PostBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: BlocListener<PostBloc, PostState>(
        bloc: postBloc,
        listener: (context, state) {
          if (state is PostLoading) {
            showDialog(
                context: context,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          } else if (state is PostSuccess) {
            if (state.posts == null) {
              postBloc.add(
                  GetPostsEvent(uid: FirebaseAuth.instance.currentUser!.uid));
            }
            Navigator.pop(context);
            Fluttertoast.showToast(msg: 'Post Uploaded successfully');
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Transform(
                    transform: Matrix4.translationValues(0, 10, 0),
                    child: SizedBox(
                        height: 300,
                        child: Image.file(File(widget.imagePath)))),
                FormContainerWidget(
                  hintText: 'Caption',
                  controller: captionController,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        height: 50,
                        decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        postBloc.add(PostCreateEvent(
                          photoURL: widget.imagePath,
                          content: captionController.text,
                        ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        height: 50,
                        decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
