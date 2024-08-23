import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popmeet/data/datasources/message_datasource.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:popmeet/presentation/pages/chat/chat_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            stretch: false,
            pinned: false,
            title: Row(
              children: [
                SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const TextField(
                        decoration: InputDecoration(
                      hintText: "Search Person",
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.red, width: 1.0)),
                    ))),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))
              ],
            ),
          ),
          StreamBuilder<List<Profile>>(
              stream: MessageDatasource.getInteractedProfiles(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SliverList(
                    key: const PageStorageKey("message"),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        List<String> uids = [
                          snapshot.data![index].id,
                          FirebaseAuth.instance.currentUser!.uid
                        ];
                        uids.sort();
                        String chatRoomId = uids.join("_");
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            profile: snapshot.data![index])));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      snapshot.data![index].photoPath),
                                ),
                                title: Row(
                                  children: [
                                    Text(snapshot.data![index].name),
                                    const Spacer(),
                                    (!snapshot.data![index].isOnline)
                                        ? Text(
                                            timeago
                                                .format(
                                                    snapshot
                                                        .data![index].lastOnline
                                                        .toDate(),
                                                    allowFromNow: true)
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.pink),
                                          )
                                        : const Text(
                                            "online",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.pink),
                                          )
                                  ],
                                ),
                                subtitle: StreamBuilder(
                                    stream: MessageDatasource.getMessage(
                                        chatRoomId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data!.first.senderId ==
                                                  FirebaseAuth
                                                      .instance.currentUser!.uid
                                              ? "you: ${snapshot.data!.first.text}"
                                              : snapshot.data!.first.text,
                                          style: TextStyle(
                                              fontWeight: snapshot.data!.first
                                                      .readParticipants
                                                      .contains(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                  ? FontWeight.normal
                                                  : FontWeight.bold),
                                        );
                                      } else {
                                        return const Text("No Message");
                                      }
                                    }),
                                trailing: StreamBuilder(
                                    stream: MessageDatasource.getMessage(
                                        chatRoomId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        int count = 0;
                                        snapshot.data!.forEach((element) {
                                          if (!element.readParticipants
                                              .contains(FirebaseAuth
                                                  .instance.currentUser!.uid)) {
                                            count++;
                                          }
                                        });
                                        if (count > 0) {
                                          return SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: CircleAvatar(
                                                backgroundColor: Colors.pink,
                                                child: Text(
                                                  count.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )),
                                          );
                                        } else {
                                          return const Text("");
                                        }
                                      } else {
                                        return const Text("No Message");
                                      }
                                    }),
                              ),
                            ));
                      },
                      childCount: snapshot.data?.length ?? 0,
                    ),
                  );
                } else {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(CupertinoIcons.person_3_fill),
      ),
    );
  }
}
