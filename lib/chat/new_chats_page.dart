import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

import '../main.dart';
import '/util/types.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({
    super.key,
  });

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final searchInputFocus = FocusNode();
  final nameInputFocus = FocusNode();
  List<DocumentReference> selected = [];
  List<UserT> friends = [];
  bool editing = false;
  String chatName = "New Chat";
  Widget resList = const Center();
  Fuzzy? fuse;

  @override
  void initState() {
    super.initState();
    searchInputFocus.requestFocus();
    getFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildNameEntry(),
        actions: [
          IconButton(
            onPressed: () {
              db.collection("chats").get().then((chatSnapshot) {
                selected.add(db.collection("users").doc(getCurrentUser()!.id));
                createChat(
                  Chat(
                    name: chatName,
                    id: chatSnapshot.size.toString(),
                    users: selected,
                  ),
                );
              });
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Visibility(
          //   visible: false,
          //   child: ListView.builder(
          //     itemBuilder: (context, index) =>
          //         _buildSelectedUser(context, selected[index]),
          //     itemCount: selected.length,
          //     scrollDirection: Axis.horizontal,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "To: ",
                labelStyle: TextStyle(
                  color: ThemeColors.accent,
                ),
              ),
              style: const TextStyle(color: ThemeColors.textOnPrimary),
              textInputAction: TextInputAction.search,
              focusNode: searchInputFocus,
              onChanged: (String input) {
                setState(() {
                  resList = buildSuggestions(context, input);
                });
              },
            ),
          ),
          Expanded(
            key: UniqueKey(),
            child: resList,
          ),
        ],
      ),
    );
  }

  Widget buildNameEntry() {
    if (editing) {
      return TextField(
        style: const TextStyle(
          color: ThemeColors.accent,
          fontSize: 36,
        ),
        textAlign: TextAlign.center,
        focusNode: nameInputFocus,
        decoration: const InputDecoration(
          hintText: "Chat Name",
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
        ),
        onChanged: (input) {
          chatName = input;
        },
        onSubmitted: (input) {
          setState(() {
            chatName = input.isEmpty ? "New Chat" : input;
            editing = false;
          });
        },
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            editing = true;
          });
          searchInputFocus.unfocus();
          nameInputFocus.requestFocus();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(chatName),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.edit_outlined),
            ),
          ],
        ),
      );
    }
  }

  Widget buildSuggestions(BuildContext context, String input) {
    if (fuse != null) {
      var ordering = fuse!.search(input);
      ordering.sort((r1, r2) => (r1.score).compareTo(r2.score));
      List<UserT> results = [];
      for (var res in ordering) {
        results.add(friends[res.matches[0].arrayIndex]);
      }
      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => _buildResultTile(context, results[index]),
      );
    } else if (input.isEmpty) {
      return const Center();
    } else {
      return const Center(
        child: Text("Results are loading."),
      );
    }
  }

  Widget _buildResultTile(BuildContext context, UserT user) {
    var ref = db.collection("users").doc(user.id);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected.contains(ref)) {
                      selected.remove(ref);
                    } else {
                      selected.add(ref);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    user.displayName!,
                    style: TextStyle(
                      // TODO fix this
                      color: (selected.contains(ref))
                          ? ThemeColors.accent
                          : ThemeColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  void createChat(Chat chat) {
    db.collection("chats").doc(chat.id).set(chat.toEntry());
  }

// Widget _buildSelectedUser(BuildContext context, User user) {
//
// }

  void getFriends() {
    List<String> displayNames = [];
    UserT u;
    var usersRef = db.collection("users");
    usersRef.doc(getCurrentUser()?.id).collection("friends").get().then((snapshot) {
      for (var friendID in snapshot.docs) {
        usersRef.doc(friendID.id).get().then((friend) {
          u = UserT.fromEntry(friend.data()!);
          friends.add(u);
          displayNames.add(u.displayName!);
        });
      }
      fuse = Fuzzy(displayNames);
    });
  }
}
