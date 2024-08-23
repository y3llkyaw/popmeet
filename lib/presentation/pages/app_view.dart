import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popmeet/data/datasources/message_datasource.dart';
import 'package:popmeet/domain/entities/message.dart';
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/chat/message_page.dart';
import 'package:popmeet/presentation/pages/home/home_page2.dart';
import 'package:popmeet/presentation/pages/home/profile_page.dart';
import 'package:popmeet/presentation/pages/home/people_page.dart';

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
        const SafeArea(child: HomePage2()),
        const SafeArea(child: PeoplePage()),
        BlocBuilder<ProfileBloc, ProfileState>(
          bloc: profileBloc,
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
        tooltip: 'Messages',
        backgroundColor: Colors.grey.shade200,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const MessagePage();
          }));
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              CupertinoIcons.chat_bubble_2_fill,
            ),
            Transform(
              transform: Matrix4.translationValues(20, -15, 0),
              child: Container(
                height: 22,
                width: 22,
                child: StreamBuilder<List<Message>?>(
                    stream: MessageDatasource.getUserMessage(),
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.data != null) {
                        for (var message in snapshot.data!) {
                          if (message.readParticipants.contains(
                              FirebaseAuth.instance.currentUser!.uid)) {
                            continue;
                          } else {
                            print(message.readParticipants);
                            count++;
                          }
                        }
                      }
                      return count > 0
                          ? CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            )
                          : Container();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
