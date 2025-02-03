import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portal/util/misc.dart';

class Message {
  final String text;
  final Timestamp time;
  final DocumentReference sentBy;

  const Message({
    required this.text,
    required this.time,
    required this.sentBy,
  });

  static Message fromEntry(Entry entry) {
    return Message(
        text: entry["text"],
        time: entry["time"],
        sentBy: entry["sentBy"] as DocumentReference
    );
  }

  Entry toEntry() {
    return {
      "text": text,
      "time": time,
      "sentBy": sentBy,
    };
  }

  @override
  String toString() {
    return "Message {Text: $text, Time: $time, SentBy: $sentBy}";
  }
}