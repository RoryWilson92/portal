import 'package:flutter/material.dart';
import 'package:portal/model/new_chat_model.dart';
import 'package:portal/model/types/user.dart';
import 'package:portal/model/user_model.dart';
import 'package:portal/theme/app_theme.dart';
import 'package:provider/provider.dart';

class NewChatPage extends StatelessWidget {
  NewChatPage({super.key});

  final searchInputFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    searchInputFocus.requestFocus();
    return Consumer<NewChatModel>(
      builder: (context, newChatModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Chat Name",
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
              ),
              enabled: newChatModel.chatMembers.length > 1,
              onChanged: (input) {
                newChatModel.chatName = input;
              },
              onSubmitted: (input) {
                newChatModel.chatName = input.isEmpty ? "New Chat" : input;
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (newChatModel.chatMembers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            "Please add at least one member to the chat"),
                      ),
                    );
                  } else {
                    newChatModel
                        .addMember(context.read<UserModel>().currentUser!.ref);
                    newChatModel.createChat();
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "To: ",
                    labelStyle: TextStyle(
                      color: AppTheme.accent,
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textOnPrimary),
                  textInputAction: TextInputAction.search,
                  focusNode: searchInputFocus,
                  onChanged: (String input) {
                    newChatModel.searchFriends(input);
                  },
                ),
              ),
              Expanded(
                key: UniqueKey(),
                child: ListView.builder(
                  itemCount: newChatModel.results.length,
                  itemBuilder: (context, index) =>
                      _ResultTile(user: newChatModel.results[index].item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.user});

  final UserT user;

  @override
  Widget build(BuildContext context) {
    return Consumer<NewChatModel>(
      builder: (context, newChatModel, child) {
        return GestureDetector(
          onTap: () {
            newChatModel.toggleMember(user.ref);
          },
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Consumer<NewChatModel>(
                      builder: (context, newChatModel, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            user.displayName!,
                            style: TextStyle(
                              color: newChatModel.chatMembers.contains(user.ref)
                                  ? AppTheme.accent
                                  : AppTheme.textOnPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}
