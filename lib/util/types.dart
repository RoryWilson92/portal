import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

var rollo = const UserT(
  username: "rollodyson",
  displayName: "Rollo Kennedy-Dyson",
  id: "0",
);
var angus = const UserT(
  username: "angusgibby",
  displayName: "Angus Gibby",
  id: "1",
);
var josh = const UserT(
  username: "joshfarmer",
  displayName: "Josh Farmer",
  id: "2",
);

class ThemeColors {
  static const double zeroGR = 0.61803398875;
  static const double oneGR = 1 + zeroGR;

  static const Color textOnPrimary = Color.fromRGBO(255, 255, 255, 1);
  static const Color textOnAccent = Color.fromRGBO(0, 0, 0, 1);
  static const Color accent = Color.fromRGBO(255, 255, 0, 1);
  static final Color primary = darker(textOnPrimary, degree: 5);
  static final Color primaryContrast = lighter(primary);

  static Color darker(Color color, {int degree = 1}) {
    return color
        .withRed((color.red * pow(zeroGR, degree)).toInt())
        .withGreen((color.green * pow(zeroGR, degree)).toInt())
        .withBlue((color.blue * pow(zeroGR, degree)).toInt());
  }

  static Color lighter(Color color, {int degree = 1}) {
    return color
        .withRed((color.red * pow(oneGR, degree)).toInt())
        .withGreen((color.green * pow(oneGR, degree)).toInt())
        .withBlue((color.blue * pow(oneGR, degree)).toInt());
  }

  static Color opacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

class Message {
  final String text;
  final Timestamp time;
  final UserT sentBy;

  const Message({
    required this.text,
    required this.time,
    required this.sentBy,
  });

  static Future<Message> fromEntry(Entry entry) async {
    return (entry["sentBy"] as DocumentReference).get().then((userSnapshot) {
      return Message(
          text: entry["text"],
          time: entry["time"],
          sentBy: UserT.fromEntry(userSnapshot.data() as Map<String, dynamic>));
    });
  }

  Entry toEntry() {
    return {
      "text": text,
      "time": time,
      "sentBy": db.collection("users").doc(sentBy.id),
    };
  }

  @override
  String toString() {
    return "Message {Text: $text, Time: $time, SentBy: $sentBy}";
  }
}

class Post {
  final UserT user;
  final String downloadURL;
  final String caption;
  final List<String> comments;
  final List<String> reactions;
  final List<DocumentReference> tagged;

  const Post({
    required this.user,
    required this.downloadURL,
    required this.caption,
    required this.comments,
    required this.reactions,
    required this.tagged,
  });

  Entry toEntry() {
    return {
      "user": db.collection("users").doc(user.id),
      "downloadURL": downloadURL,
      "caption": caption,
      "comments": comments,
      "reactions": reactions,
      "tagged": tagged,
    };
  }

  static Future<Post> fromEntry(Entry entry) {
    return (entry["user"] as DocumentReference).get().then((userSnapshot) {
      return Post(
        user: UserT.fromEntry(userSnapshot.data() as Map<String, dynamic>),
        downloadURL: entry["downloadURL"],
        caption: entry["caption"],
        comments: entry["comments"],
        reactions: entry["reactions"],
        tagged: List.from(entry["tagged"]),
      );
    });
  }
}

class Chat {
  final String name;
  final String id;
  List<DocumentReference> users;

  Chat({
    required this.name,
    required this.id,
    required this.users,
  });

  @override
  String toString() {
    return "Chat {Name: $name, id: $id, Users: $users}";
  }

  static Chat fromEntry(Entry entry) {
    return Chat(
      name: entry["name"],
      id: entry["id"],
      users: List.from(entry["users"]),
    );
  }

  Entry toEntry() {
    return {
      "name": name,
      "id": id,
      "users": users,
    };
  }

  void addUser(DocumentReference ref) {
    users.add(ref);
  }

  void removeUser(DocumentReference ref) {
    users.remove(ref);
  }
}

class UserT {
  final String username;
  final String? displayName;
  final String id;

  const UserT({
    required this.username,
    required this.displayName,
    required this.id,
  });

  static UserT fromEntry(Entry entry) {
    return UserT(
      username: entry["username"],
      displayName: entry["displayName"],
      id: entry["id"],
    );
  }

  Entry toEntry() {
    return {
      "username": username,
      "displayName": displayName,
      "id": id,
    };
  }

  void sendFriendRequest(String userID) {
    db.collection("users").doc(userID).collection("friendRequests").doc(id).set({"id": id});
  }

  void addFriend(String userID) {
    db.collection("users").doc(id).collection("friends").doc(userID).set({"id": userID});
    db.collection("users").doc(userID).collection("friends").doc(id).set({"id": id});
  }

  void removeFriend(String userID) {
    db.collection("users").doc(id).collection("friends").doc(userID).delete();
    db.collection("users").doc(userID).collection("friends").doc(id).delete();
  }
}

class SignInException implements Exception {
  String cause;

  SignInException(this.cause);
}

typedef Entry = Map<String, dynamic>;
