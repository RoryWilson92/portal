import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal/model/types/user.dart';
import 'package:portal/main.dart';
import 'package:portal/util/misc.dart';

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