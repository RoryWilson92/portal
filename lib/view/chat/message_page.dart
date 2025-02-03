import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:portal/model/inbox_model.dart';
import 'package:portal/model/user_model.dart';
import 'package:portal/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:portal/model/types/message.dart';
import 'package:portal/util/misc.dart';

class MessagePage extends StatelessWidget {

  final textInputController = TextEditingController();
  final textInputFocus = FocusNode();

  MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InboxModel>(
      builder: (BuildContext context, InboxModel inboxModel, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(inboxModel.selectedChat.getDisplayName(context.read<UserModel>())),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: inboxModel.selectedChat.messageStream,
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading"));
                    }
                    return ListView(
                      children: snapshot.data!.docs.map((messageSnapshot) {
                        return MessageWidget(message: Message.fromEntry(
                            messageSnapshot.data() as Map<String, dynamic>));
                      }).toList(),
                    );
                  },
                ),
              ),
              Container(
                color: AppTheme.primaryContrast,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Send a message",
                  ),
                  style: const TextStyle(color: AppTheme.textOnPrimary),
                  textInputAction: TextInputAction.send,
                  controller: textInputController,
                  focusNode: textInputFocus,
                  onSubmitted: (String msg) {
                    try {
                      inboxModel.sendMessage(
                        Message(
                          text: msg,
                          time: Timestamp.now(),
                          sentBy: context
                              .read<UserModel>()
                              .currentUser!
                              .ref,
                        ),
                      );
                      textInputController.clear();
                      textInputFocus.requestFocus();
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
    );
  }
}

class MessageWidget extends StatelessWidget {

  final Message message;

  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const VerticalDivider(
              thickness: 2.5,
              color: AppTheme.accent,
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.read<InboxModel>().selectedChat.getUser(message.sentBy)!.displayName!,
                  // message.sentBy.displayName!,
                  style: const TextStyle(
                    color: AppTheme.accent,
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
