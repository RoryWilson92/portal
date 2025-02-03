import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal/model/types/user.dart';

import 'package:portal/main.dart';
import 'package:portal/model/user_model.dart';
import 'package:portal/util/misc.dart';


class Chat {
  final String id;
  final String? name; // if name is null, it is a direct chat
  late Stream<QuerySnapshot> _messageStream;
  late Map<DocumentReference, UserT?> _members;

  Chat({
    required this.id,
    required this.name,
    required Iterable<DocumentReference> userRefs,
  }) {
    fetchUsers(userRefs);
    _messageStream = db
        .collection('chats')
        .doc(id)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Stream<QuerySnapshot> get messageStream => _messageStream;

  UserT? getUser(DocumentReference ref) {
    return _members[ref];
  }

  Chat.defaultChat() : this(id: "-1", name: "", userRefs: []);

  @override
  String toString() {
    return "Chat {Name: $name, id: $id, Users: ${_members.values}}";
  }

  static Chat fromEntry(Entry entry) {
    return Chat(
      id: entry["id"],
      name: entry["name"],
      userRefs: List.from(entry["users"]),
    );
  }

  Entry toEntry() {
    return {
      "id": id,
      "name": name,
      "users": _members.keys.toList(),
    };
  }

  void fetchUsers(Iterable<DocumentReference> userRefs) async {
    _members = Map.fromEntries(
        userRefs.map((DocumentReference ref) => MapEntry(ref, null)));
    await Future.wait(
        userRefs.map((DocumentReference ref) => ref.get().then((snapshot) {
              _members[ref] =
                  UserT.fromEntry(snapshot.data() as Map<String, dynamic>);
            })));
  }

  String getDisplayName(UserModel userModel) {
    return name ?? (_getRecipient(userModel)!.displayName ?? "");
  }

  UserT? _getRecipient(UserModel userModel) {
    // this is only called when the chat is a DM, so we can assume that the
    // members list contains only the current user and the recipient.

    // the user objects (in members) are not guaranteed to be on the client
    // when this is called, thus we search the current user's friends list
    // (which is guaranteed to be on the client) for the recipient. since DMs
    // are only between friends, this is guaranteed to work.

    // return null if group chat
    return _members.length > 2
        ? null
        : userModel.friends?.firstWhere((friend) => _members.keys.contains(friend.ref));
  }
}
