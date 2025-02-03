import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal/main.dart';
import 'package:portal/util/misc.dart';

class UserT {
  final String username;
  final String? displayName;
  final String id;
  final Set<DocumentReference<Entry>> friends;
  final Set<DocumentReference<Entry>> friendRequests;

  const UserT({
    required this.username,
    required this.displayName,
    required this.id,
    required this.friends,
    required this.friendRequests,
  });

  static UserT fromEntry(Entry entry) {
    return UserT(
      username: entry["username"],
      displayName: entry["displayName"],
      id: entry["id"],
      friends: Set.of(entry["friends"]),
      friendRequests: Set.of(entry["friendRequests"]),
    );
  }

  Entry toEntry() {
    return {
      "username": username,
      "displayName": displayName,
      "id": id,
      "friends": friends.toList(),
      "friendRequests": friendRequests.toList(),
    };
  }

  DocumentReference<Entry> get ref => db.collection("users").doc(id);
}