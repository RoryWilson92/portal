import 'package:flutter/material.dart';
import 'package:portal/model/types/post.dart';

class UserPost extends StatelessWidget {

  final Post post;

  const UserPost({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(post.user.displayName!),
        Image(
          image: NetworkImage(post.downloadURL),
        ),
        Text(post.caption),
        Row(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: "Add a comment",
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.emoji_emotions,
              ),
              onPressed: () {},
            )
          ],
        ),
      ],
    );
  }
}