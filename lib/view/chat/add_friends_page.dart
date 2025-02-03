import 'package:flutter/material.dart';

import 'package:portal/model/add_friends_model.dart';
import 'package:portal/model/types/user.dart';
import 'package:portal/model/user_model.dart';

import 'package:portal/theme/app_theme.dart';
import 'package:provider/provider.dart';

class AddFriendsPage extends StatelessWidget {
  const AddFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
      ),
      body: Consumer<AddFriendsModel>(
        builder: (context, addFriendsModel, child) {
          return Column(
            children: [
              Visibility(
                visible: addFriendsModel.requests.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      const Text("Friend Requests"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: addFriendsModel.requests.length,
                        itemBuilder: (context, index) => _RequestTile(user: addFriendsModel.requests[index]),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  decoration: const InputDecoration(label: Icon(Icons.search)),
                  style: const TextStyle(color: AppTheme.textOnPrimary),
                  textInputAction: TextInputAction.search,
                  onChanged: (String input) {
                    addFriendsModel.searchUsers(input);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: addFriendsModel.results.length,
                  itemBuilder: (context, index) => _ResultTile(user: addFriendsModel.results[index].item),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.user});

  final UserT user;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(user.username),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: IconButton(
                    onPressed: () => userModel.acceptRequest(user),
                    icon: const Icon(Icons.check),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                    onPressed: () => userModel.rejectRequest(user),
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
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
    return GestureDetector(
      onTap: () {
        var userModel = context.read<UserModel>();
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Center(
              child: Text(user.displayName!),
            ),
            content: ElevatedButton(
              child: const Text("Add friend"),
              onPressed: () {
                userModel.sendFriendRequest(user);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(user.username),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
