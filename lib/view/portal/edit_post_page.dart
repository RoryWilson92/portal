import 'dart:io';

import 'package:portal/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:portal/main.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as dev;

import 'package:portal/model/user_model.dart';

import 'package:portal/model/types/post.dart';

class EditPostPage extends StatefulWidget {

  const EditPostPage({
    super.key,
    required this.image,
  });

  final XFile image;

  @override
  State<EditPostPage> createState() => _EditPostPageState();

}

class _EditPostPageState extends State<EditPostPage> {

  final String _caption = "";
  final List<DocumentReference> _tagged = [];
  double progress = 0;
  bool posting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  posting = true;
                });
                sendPost(context);
              },
              child: const Text("Post"),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Image border
                    child: Image.file(File(widget.image.path)),
                  ),
                ),
                Center(
                  child: Visibility(
                    visible: posting,
                    child: CircularProgressIndicator(
                      backgroundColor: AppTheme.textOnAccent,
                      color: AppTheme.accent,
                      value: progress,
                    ),
                  ),
                ),
              ],
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: "Add caption",
              ),
            ),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () {

                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Tag Friends"),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void sendPost(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentUser = context.read<UserModel>().currentUser;
    storage
        .child("posts")
        .child(today.toString())
        .child("${currentUser!.id}.jpg")
        .putFile(File(widget.image.path))
        .snapshotEvents
        .listen((taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          setState(() {
            progress = (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          });
          break;
        case TaskState.paused:
          break;
        case TaskState.success:
          dev.log("Post upload success");
          final downloadURL = await storage.child("posts").child(today.toString()).child("${currentUser.id}.jpg").getDownloadURL();
          final post = Post(user: currentUser, downloadURL: downloadURL, caption: _caption, comments: [], reactions: [], tagged: _tagged);
          db.collection("posts").doc(today.toString()).collection("posts").add(post.toEntry());
          if (!mounted) return;
          Navigator.pop(context, true);
          break;
        case TaskState.canceled:
          dev.log("Post upload cancelled");
          if (!mounted) return;
          Navigator.pop(context, false);
          break;
        case TaskState.error:
          dev.log("Post upload error");
          if (!mounted) return;
          Navigator.pop(context, false);
          break;
      }
    });
  }
}