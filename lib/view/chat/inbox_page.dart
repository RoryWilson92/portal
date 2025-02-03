import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:portal/model/add_friends_model.dart';
import 'package:portal/model/inbox_model.dart';
import 'package:portal/model/new_chat_model.dart';
import 'package:portal/model/page_model.dart';
import 'package:portal/model/types/chat.dart';
import 'package:portal/model/user_model.dart';
import 'package:portal/view/chat/new_chats_page.dart';
import 'package:portal/view/misc/settings_page.dart';
import 'package:provider/provider.dart';

import 'package:portal/view/chat/add_friends_page.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            onPressed: () {
              var userModel = context.read<UserModel>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: userModel),
                      ChangeNotifierProvider(
                          create: (context) =>
                              AddFriendsModel(friendRequests: userModel.currentUser!.friendRequests.toList())),
                    ],
                    child: AddFriendsPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            padding: const EdgeInsets.all(10.0),
          ),
          IconButton(
            onPressed: () {
              var userModel = context.read<UserModel>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: userModel,
                    builder: (context, child) => const SettingsPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Consumer<InboxModel>(builder: (context, chatsModel, child) {
            return StreamBuilder(
              stream: chatsModel.chatsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (context.watch<UserModel>().friends == null) {
                  return const CircularProgressIndicator();
                }
                return ListView(
                  children: snapshot.data!.docs
                      .map((chatSnapshot) {
                        return ChatTile(
                            chat: Chat.fromEntry(
                                chatSnapshot.data() as Map<String, dynamic>));
                      })
                      .toList()
                      .cast(),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var userModel = context.read<UserModel>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: userModel),
                  ChangeNotifierProvider(
                      create: (context) =>
                          NewChatModel(friends: userModel.friends!.toList())),
                ],
                child: NewChatPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Chat chat;

  const ChatTile({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onHorizontalDragEnd: (details) {
      //   context.read<InboxModel>().selectedChat = chat;
      // },
      onTapDown: (details) {
        context.read<InboxModel>().selectedChat = chat;
      },
      onTapUp: (details) {
        context.read<PageModel>().setPage(0);
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(chat.getDisplayName(context.read<UserModel>())),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
