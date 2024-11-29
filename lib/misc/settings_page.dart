import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '/misc/sign_in_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  ImageProvider profilePic = const AssetImage("assets/blank-profile-picture.png");

  @override
  void initState() {
    getProfilePic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50),
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: profilePic,
                      child: GestureDetector(
                        onTap: () async {
                          var img = (await showDialog(context: context, builder: _buildPopup)) as XFile;
                          storage
                              .child("users")
                              .child(getCurrentUser()!.id)
                              .child("profile_picture.jpg")
                              .putFile(File(img.path))
                              .snapshotEvents
                              .listen((taskSnapshot) {
                            switch (taskSnapshot.state) {
                              case TaskState.running:
                                break;
                              case TaskState.paused:
                                break;
                              case TaskState.success:
                                getProfilePic();
                                break;
                              case TaskState.canceled:
                                print("PP upload cancelled");
                                break;
                              case TaskState.error:
                                print("PP upload error");
                                break;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      getCurrentUser()!.displayName!,
                      style: const TextStyle(
                        fontSize: 42,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        handleSignOut();
                        setState(() {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("Sign Out"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getProfilePic() async {
    try {
      var tmp = NetworkImage(
          await storage.child("users").child(getCurrentUser()!.id).child("profile_picture.jpg").getDownloadURL());
      setState(() {
        profilePic = tmp;
      });
    } catch (e) {
      setState(() {
        profilePic = const AssetImage("assets/blank-profile-picture.png");
      });
    }
  }

  Widget _buildPopup(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Change Picture:")),
      actions: [
        ElevatedButton(
          child: const Text("Camera"),
          onPressed: () async {
            var img = await _picker.pickImage(source: ImageSource.camera);
            if (!mounted) return;
            Navigator.pop(context, img);
          },
        ),
        ElevatedButton(
          child: const Text("Gallery"),
          onPressed: () async {
            var img = await _picker.pickImage(source: ImageSource.gallery);
            if (!mounted) return;
            Navigator.pop(context, img);
          },
        ),
      ],
      titlePadding: const EdgeInsets.only(top: 20),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
