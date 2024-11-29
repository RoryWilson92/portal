import 'dart:io';

import 'package:portal/util/types.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

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
                sendPost();
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
                      backgroundColor: ThemeColors.textOnAccent,
                      color: ThemeColors.accent,
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

  void sendPost() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    storage
        .child("posts")
        .child(today.toString())
        .child("${getCurrentUser()!.id}.jpg")
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
          print("Post upload success");
          final downloadURL = await storage.child("posts").child(today.toString()).child("${getCurrentUser()!.id}.jpg").getDownloadURL();
          final post = Post(user: getCurrentUser()!, downloadURL: downloadURL, caption: _caption, comments: [], reactions: [], tagged: _tagged);
          db.collection("posts").doc(today.toString()).collection("posts").add(post.toEntry());
          if (!mounted) return;
          Navigator.pop(context, true);
          break;
        case TaskState.canceled:
          print("Post upload cancelled");
          if (!mounted) return;
          Navigator.pop(context, false);
          break;
        case TaskState.error:
          print("Post upload error");
          if (!mounted) return;
          Navigator.pop(context, false);
          break;
      }
    });
  }
}