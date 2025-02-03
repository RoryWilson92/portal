import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:portal/main.dart';
import 'package:portal/model/types/chat.dart';
import 'package:portal/model/types/message.dart';
import 'package:portal/model/types/user.dart';

class InboxModel extends ChangeNotifier {

  late final Stream<QuerySnapshot> _chatsStream;
  late Chat _selectedChat;

  Stream<QuerySnapshot> get chatsStream => _chatsStream;

  Chat get selectedChat => _selectedChat;
  set selectedChat(Chat value) {
    _selectedChat = value;
    notifyListeners();
  }

  InboxModel(UserT? user) {
    selectedChat = Chat.defaultChat();
    _chatsStream = db.collection('chats').where("users", arrayContains: db.collection("users").doc(user?.id)).snapshots();
  }

  void sendMessage(Message message) {
    db.collection("chats").doc(selectedChat.id).collection("messages").add(message.toEntry());
  }
}