import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:portal/main.dart';
import 'package:portal/model/types/chat.dart';
import 'package:portal/model/types/user.dart';

class NewChatModel extends ChangeNotifier {

  final Iterable<UserT> friends;
  final Set<DocumentReference> _chatMembers = {};
  String? chatName;
  List<Result<UserT>> results = [];
  late Fuzzy<UserT> fuzzySearch;
  final FuzzyOptions<UserT> fuzzyOptions = FuzzyOptions(
    keys: [
      // search by display name
      WeightedKey<UserT>(
        name: "displayName",
        getter: (user) => user.displayName!,
        weight: 1,
      ),
    ],
  );

  get chatMembers => _chatMembers;

  NewChatModel({required this.friends}) {
    fuzzySearch = Fuzzy(friends.toList(), options: fuzzyOptions);
  }
  
  void toggleMember(DocumentReference ref) {
    if (_chatMembers.contains(ref)) {
      removeMember(ref);
    } else {
      addMember(ref);
    }
  }
  
  void addMember(DocumentReference ref) {
    _chatMembers.add(ref);
    notifyListeners();
  }
  
  void removeMember(DocumentReference ref) {
    _chatMembers.remove(ref);
    notifyListeners();
  }

  void searchFriends(String input) {
    results = (input.isEmpty) ? [] : fuzzySearch.search(input);
    notifyListeners();
  }

  void createChat() {
    db.collection("chats").get().then((chatSnapshot) {
      var chat = Chat(
        name: _chatMembers.length > 1 ? chatName : null,
        id: chatSnapshot.size.toString(),
        userRefs: _chatMembers,
      );
      db.collection("chats").doc(chat.id).set(chat.toEntry());
    });
  }
}