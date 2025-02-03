import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:portal/model/types/user.dart';
import 'package:portal/main.dart';
import 'package:portal/util/misc.dart';

class AddFriendsModel extends ChangeNotifier {

  late Iterable<UserT> users;
  late Fuzzy<UserT> fuzzySearch;
  Iterable<DocumentReference<Entry>> friendRequests;
  List<UserT> requests = [];
  List<Result<UserT>> results = [];
  FuzzyOptions<UserT> fuzzyOptions = FuzzyOptions(
    keys: [
      // search by username name
      WeightedKey<UserT>(
        name: "userName",
        getter: (user) => user.username,
        weight: 1,
      ),
    ],
  );

  AddFriendsModel({required this.friendRequests}) {
    _getUsers();
    _getRequests();
  }

  void searchUsers(String input) {
    results = (input.isEmpty) ? [] : fuzzySearch.search(input);
    notifyListeners();
  }

  void _getRequests() {
    Future.wait(friendRequests.map((userRef) => userRef.get()))
        .then((requestsList) {
          requests = requestsList.map((user) => UserT.fromEntry(user.data()!)).toList();
          notifyListeners();
        });
  }

  void _getUsers() {
    db.collection("users").get().then((snapshot) {
      users = snapshot.docs.map((user) => UserT.fromEntry(user.data()));
      fuzzySearch = Fuzzy(users.toList(), options: fuzzyOptions);
    });
  }
}