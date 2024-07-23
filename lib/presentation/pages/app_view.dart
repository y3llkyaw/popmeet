import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/home/home_page.dart';
import 'package:popmeet/presentation/pages/home/profile_page.dart';
import 'package:popmeet/presentation/pages/home/people_page.dart';
import 'package:popmeet/presentation/pages/post/addPost.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final postBloc = BlocProvider.of<PostBloc>(context);
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc
        .add(GetAllProfilesEvent(FirebaseAuth.instance.currentUser!.uid));
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
            elevation: 0,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.grey.shade300,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: selectedIndex,
            onTap: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Transform(
                  transform: Matrix4.translationValues(0, 10, 0),
                  child: const Icon(
                    CupertinoIcons.news_solid,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Transform(
                  transform: Matrix4.translationValues(0, 10, 0),
                  child: const Icon(
                    CupertinoIcons.person_2_fill,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Transform(
                  transform: Matrix4.translationValues(0, 10, 0),
                  child: const Icon(
                    CupertinoIcons.profile_circled,
                  ),
                ),
                label: 'Products',
              ),
            ]),
      ),
      body: [
        const SafeArea(child: Home()),
        const SafeArea(child: PeoplePage()),
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfilesLoaded) {
              return SafeArea(
                  child: ProfilePage(
                profile: state.userProfile,
              ));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ][selectedIndex],
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Add Post',
        backgroundColor: Colors.grey.shade200,
        shape: const CircleBorder(),
        onPressed: () async {
          var image =
              await ImagePicker().pickImage(source: ImageSource.gallery);

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
        child: const Icon(CupertinoIcons.camera_circle),
      ),
    );
  }
}
