import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
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
              stretch: true,
              floating: true,
              snap: true,
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
            StreamBuilder(
                stream: ProfileDatasource.getAllPeople(),
                builder: (context, snapshot) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return InkWell(
                          onTap: () {},
                          child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: Hero(
                                  tag: snapshot.data![index],
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data![index].photoPath),
                                  ),
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
                                                  snapshot
                                                      .data![index].lastOnline
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
                      },
                      childCount: snapshot.data?.length ?? 0,
                    ),
                  );
                }),
          ],
        ));
  }
}
