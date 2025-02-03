import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:portal/model/user_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              child: Consumer<UserModel>(
                builder: (BuildContext context, UserModel userModel, Widget? child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: userModel.profilePic,
                          child: GestureDetector(
                            onTap: () async {
                              var img = (await showDialog(context: context, builder: (context) {
                                return const ProfilePicPicker();
                              })) as XFile;
                              userModel.saveProfilePic(img);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          userModel.currentUser!.displayName!,
                          style: const TextStyle(
                            fontSize: 42,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          onPressed: userModel.handleSignOut,
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Text("Sign Out"),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePicPicker extends StatelessWidget {
  const ProfilePicPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    return AlertDialog(
      title: const Center(child: Text("Change Picture:")),
      actions: [
        ElevatedButton(
          child: const Text("Camera"),
          onPressed: () async {
            var img = await picker.pickImage(source: ImageSource.camera);
            Navigator.pop(context, img);
          },
        ),
        ElevatedButton(
          child: const Text("Gallery"),
          onPressed: () async {
            var img = await picker.pickImage(source: ImageSource.gallery);
            Navigator.pop(context, img);
          },
        ),
      ],
      titlePadding: const EdgeInsets.only(top: 20),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}