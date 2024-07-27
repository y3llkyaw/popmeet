import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/chat/chat_page.dart';
import 'package:popmeet/presentation/pages/home/profile_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});
  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    final people = ProfileDatasource.getAllPeople();

    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        profileBloc
            .add(GetAllProfilesEvent(FirebaseAuth.instance.currentUser!.uid));
      },
      child: StreamBuilder(
          stream: people,
          builder: (context, snapshot) {
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  if (snapshot.data![index].id ==
                      FirebaseAuth.instance.currentUser!.uid) {
                    return Container();
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(snapshot.data![index].name),
                                    ),
                                    body: ProfilePage(
                                      profile: snapshot.data![index],
                                    ),
                                  )));
                    },
                    child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapshot.data![index].photoPath),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(snapshot.data![index].name),
                            const Spacer(),
                            (!snapshot.data![index].isOnline)
                                ? Text(
                                    timeago
                                        .format(
                                            snapshot.data![index].lastOnline
                                                .toDate(),
                                            allowFromNow: true)
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.pink),
                                  )
                                : const Text(
                                    "online",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.pink),
                                  )
                          ],
                        ),
                        subtitle: Text(snapshot.data![index].bio ?? ''),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                        profile: snapshot.data![index])));
                          },
                          icon: Icon(
                            size: 30,
                            CupertinoIcons.chat_bubble_2_fill,
                            color: snapshot.data![index].isOnline
                                ? Colors.pinkAccent
                                : Colors.grey,
                          ),
                        )),
                  );
                });
          }),
    ));
  }
}
