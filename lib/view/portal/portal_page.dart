import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:portal/main.dart';
import 'package:portal/model/types/post.dart';
import 'package:portal/view/portal/edit_post_page.dart';
import 'package:portal/view/portal/user_post.dart';

class PortalPage extends StatefulWidget {
  const PortalPage({
    super.key,
  });

  @override
  State<PortalPage> createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {

  final ImagePicker _picker = ImagePicker();
  final Stream<QuerySnapshot> _postsStream = db.collection("posts").doc(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString()).collection("posts").snapshots();
  bool posted = false;

  @override
  Widget build(BuildContext context) {
    if (posted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Portal"),
        ),
        body: Center(
          child: StreamBuilder(
            stream: _postsStream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }
              return ListView(
                children: snapshot.data!.docs
                    .map((postSnapshot) async {
                  return UserPost(post: await Post.fromEntry(postSnapshot as Map<String, dynamic>));
                })
                    .toList()
                    .cast(),
              );
            },
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Portal"),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text("Add Daily Post"),
            ),
            onPressed: () => newPost(),
          ),
        ),
      );
    }
  }

  Future<void> newPost() async {
    var img = await _picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (img != null) {
      posted = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostPage(image: img)));
    }
  }
}
