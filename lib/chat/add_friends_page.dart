import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

import '../main.dart';
import '/util/types.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  List<UserT> users = [];
  List<UserT> requests = [];
  Widget resList = const Center();
  Fuzzy? fuse;

  final Stream<QuerySnapshot> _requestsStream =
      db.collection("users").doc(getCurrentUser()!.id).collection("friendRequests").snapshots();

  void getRequests() {
    setState(() {
      requests = [];
    });
    db.collection("users").doc(getCurrentUser()!.id).collection("friendRequests").get().then((requestsSnapshot) => {
          for (var userID in requestsSnapshot.docs)
            {
              db.collection("users").doc(userID.id).get().then((user) {
                setState(() {
                  requests.add(UserT.fromEntry(user.data()!));
                });
              })
            }
        });
  }

  void acceptRequest(String userID) {
    getCurrentUser()!.addFriend(userID);
    getUsers();
    db.collection("users").doc(getCurrentUser()!.id).collection("friendRequests").doc(userID).delete();
    getRequests();
  }

  void rejectRequest(String userID) {
    db.collection("users").doc(getCurrentUser()!.id).collection("friendRequests").doc(userID).delete();
    getRequests();
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
  void initState() {
    getRequests();
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
        actions: [],
      ),
      body: Column(
        children: [
          Visibility(
            visible: requests.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  const Text("Friend Requests"),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: requests.length,
                    itemBuilder: (context, index) => _buildRequestTile(requests[index]),
                  ),
                ],
              ),
            ),
          ),
          // StreamBuilder(
          //   stream: _requestsStream,
          //   builder:
          //       (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //     if (snapshot.hasError) {
          //       return const Text('Something went wrong');
          //     }
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Text("Loading");
          //     }
          //     return Visibility(
          //       visible: snapshot.data!.docs.isNotEmpty,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 10),
          //         child: Column(
          //           children: [
          //             const Text("Friend Requests"),
          //             ListView(
          //               shrinkWrap: true,
          //               children: snapshot.data!.docs.map((requestSnapshot) {
          //                 Widget tile = Container();
          //                 db.collection("users").doc(requestSnapshot.id).get().then((userSnapshot) {
          //                   setState(() {
          //                     tile = _buildRequestTile(
          //                         UserT.fromEntry(userSnapshot.data()!));
          //                   });
          //                 });
          //                 return tile;
          //                 },
          //               ).toList().cast(),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              decoration: const InputDecoration(label: Icon(Icons.search)),
              style: const TextStyle(color: ThemeColors.textOnPrimary),
              textInputAction: TextInputAction.search,
              onChanged: (String input) {
                setState(() {
                  resList = buildSuggestions(context, input);
                });
              },
            ),
          ),
          Expanded(child: resList),
        ],
      ),
    );
  }

  Widget buildSuggestions(BuildContext context, String input) {
    try {
      var ordering = fuse!.search(input);
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
      if (input.isEmpty) {
        return const Center();
      } else {
        return const Center(
          child: Text("Loading"),
        );
      }
    }
  }

  Widget _buildRequestTile(UserT user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(user.username),
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: () => acceptRequest(user.id),
                icon: const Icon(Icons.check),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                onPressed: () => rejectRequest(user.id),
                icon: const Icon(Icons.clear),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
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
          getCurrentUser()!.sendFriendRequest(user.id);
          Navigator.pop(context);
        },
      ),
    );
  }
}
