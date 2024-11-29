import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

import '/chat/add_friends_page.dart';
import '/chat/message_page.dart';
import '/chat/new_chats_page.dart';
import '../main.dart';
import '/misc/settings_page.dart';
import '/util/types.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({
    super.key,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final Stream<QuerySnapshot> _chatsStream =
      db.collection('chats').where("users", arrayContains: db.collection("users").doc(getCurrentUser()!.id)).snapshots();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFriendsPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            padding: const EdgeInsets.all(10.0),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
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
          child: StreamBuilder(
            stream: _chatsStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }
              return ListView(
                children: snapshot.data!.docs
                    .map((chatSnapshot) {
                      return _buildChatTile(Chat.fromEntry(chatSnapshot.data() as Map<String, dynamic>));
                    })
                    .toList()
                    .cast(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NewChatPage()));
          });
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildChatTile(Chat chat) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage(selectedChat: chat),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(chat.name),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

// TODO change from delegate
class UserSearchDelegate extends SearchDelegate {
  String selected = '';
  List<UserT> users = [];

  Fuzzy? fuse;

  UserSearchDelegate() {
    getUsers();
  }

  void getUsers() {
    List<String> usernames = [];
    UserT u;
    db.collection("users").get().then((snapshot) {
      for (var user in snapshot.docs) {
        u = UserT.fromEntry(user.data());
        users.add(u);
        usernames.add(u.username);
      }
      fuse = Fuzzy(usernames);
    });
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromRGBO(37, 37, 37, 1),
        toolbarTextStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 24),
        titleTextStyle: TextStyle(
          fontFamily: "Product Sans",
          color: Color.fromRGBO(255, 255, 0, 1),
          fontSize: 36,
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(255, 255, 0, 1)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(255, 255, 0, 1)),
        ),
      ),
      fontFamily: "Product Sans",
      scaffoldBackgroundColor: const Color.fromRGBO(23, 23, 23, 1),
      hintColor: const Color.fromRGBO(255, 255, 255, 1),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 18,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color.fromRGBO(23, 23, 23, 1),
        titleTextStyle: const TextStyle(
          fontFamily: "Product Sans",
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 28,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 255, 0, 1),
              textStyle: const TextStyle(
                fontFamily: "Product Sans",
                fontSize: 18,
              ),
              foregroundColor: const Color.fromRGBO(0, 0, 0, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ))),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, selected),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    try {
      var ordering = fuse!.search(query);
      ordering.sort((r1, r2) => (r1.score).compareTo(r2.score));
      List<UserT> results = [];
      for (var res in ordering) {
        results.add(users[res.matches[0].arrayIndex]);
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => _buildResultTile(context, results[index]),
      );
    } catch (e) {
      if (query.isEmpty) {
        return const Center();
      } else {
        return const Center(
          child: Text("Results are loading."),
        );
      }
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    try {
      var ordering = fuse!.search(query);
      ordering.sort((r1, r2) => (r1.score).compareTo(r2.score));
      List<UserT> results = [];
      for (var res in ordering) {
        results.add(users[res.matches[0].arrayIndex]);
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => _buildResultTile(context, results[index]),
      );
    } catch (e) {
      if (query.isEmpty) {
        return const Center();
      } else {
        return const Center(
          child: Text("Results are loading."),
        );
      }
    }
  }

  Widget _buildResultTile(BuildContext context, UserT user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(context: context, builder: (BuildContext context) => _buildPopup(context, user));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(user.username),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildPopup(BuildContext context, UserT user) {
    return AlertDialog(
      title: Center(child: Text(user.displayName!)),
      content: ElevatedButton(
        child: const Text("Add friend"),
        onPressed: () {
          getCurrentUser()!.addFriend(user.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}
