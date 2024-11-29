import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database {
  Database._();

  static final instance = Database._();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance.ref();

  FirebaseFirestore get db => _db;

  CollectionReference get users => db.collection("users");

  CollectionReference get chats => db.collection("users");

  void sendFriendRequest({required String from, required String to}) {
    users.doc(from).collection("friendRequests").doc(to).set({"id": to});
  }
}
