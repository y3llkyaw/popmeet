import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/pages/post/postComponent.dart';
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
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return PostComponent(
                post: post,
                showDetail: true,
              );
            }));
  }
}
