import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '/util/types.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key, required this.selectedChat});

  final Chat selectedChat;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final textInputController = TextEditingController();
  final textInputFocus = FocusNode();
  late Stream<QuerySnapshot> _messageStream;

  @override
  void initState() {
    super.initState();
    _messageStream =
        db.collection('chats').doc(widget.selectedChat.id).collection("messages").orderBy("time").snapshots();
  }

  void sendMessage(Message message) {
    db.collection("chats").doc(widget.selectedChat.id).collection("messages").add(message.toEntry());
    textInputController.clear();
    textInputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedChat.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messageStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                return ListView(
                  children: snapshot.data!.docs
                      .map((messageSnapshot) {
                        return Message.fromEntry(messageSnapshot.data() as Map<String, dynamic>).whenComplete(() {
                          // return _buildMessage(this);
                        });
                      })
                      .toList()
                      .cast(),
                );
              },
            ),
          ),
          Container(
            color: ThemeColors.primaryContrast,
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Send a message",
              ),
              style: const TextStyle(color: ThemeColors.textOnPrimary),
              textInputAction: TextInputAction.send,
              controller: textInputController,
              focusNode: textInputFocus,
              onSubmitted: (String msg) {
                try {
                  sendMessage(
                    Message(
                      text: msg,
                      time: Timestamp.now(),
                      sentBy: getCurrentUser()!,
                    ),
                  );
                } catch (e) {
                  throw SignInException(
                    "Attempted to send message with null account.",
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const VerticalDivider(
              thickness: 2.5,
              color: ThemeColors.accent,
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.sentBy.displayName!,
                  style: const TextStyle(
                    color: ThemeColors.accent,
                    fontSize: 8,
                  ),
                ),
                Text(
                  message.text,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
