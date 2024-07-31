import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:popmeet/data/datasources/message_datasource.dart';
import 'package:popmeet/data/models/message_model.dart';
import 'package:popmeet/domain/entities/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  Profile profile;

  ChatPage({super.key, required this.profile});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController message = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    List<String> chatroom = [
      profile.id,
      FirebaseAuth.instance.currentUser!.uid,
    ];
    chatroom.sort();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profile.photoPath),
            ),
            Icon(
              size: 15,
              Icons.circle,
              color: profile.isOnline ? Colors.lightGreen : Colors.black,
            )
          ],
        ),
        title: Text(profile.name),
        subtitle: profile.isOnline
            ? const Text('Online')
            : Text(
                timeago
                    .format(profile.lastOnline.toDate(), allowFromNow: true)
                    .toString(),
              ),
        trailing: IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              color: Colors.blue,
            )),
      )),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: StreamBuilder<List<MessageModel>?>(
            stream: MessageDatasource.getMessage(chatroom.join("_")),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    controller: _scrollController,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: snapshot.data![index].senderId !=
                                FirebaseAuth.instance.currentUser!.uid
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(widget.profile.photoPath),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 107, 188, 255),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child:
                                              Text(snapshot.data![index].text)),
                                      Text(
                                          snapshot.data![index].createdAt
                                              .toDate()
                                              .toUtc()
                                              .toString()
                                              .substring(8, 16),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10)),
                                    ],
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 107, 188, 255),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            snapshot.data![index].text,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )),
                                      Text(
                                          snapshot.data![index].createdAt
                                              .toDate()
                                              .toUtc()
                                              .toString()
                                              .substring(8, 16),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10)),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                      );
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: message,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.paperplane_fill),
                onPressed: () {
                  MessageDatasource.addMessage([
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.profile.id
                  ], message.text);
                  message.clear();
                  // _scrollController
                  //     .jumpTo(_scrollController.position.maxScrollExtent);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
