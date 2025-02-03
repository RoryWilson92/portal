import 'dart:io';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portal/model/types/user.dart';
import 'package:portal/util/firebase_options.dart';
import 'package:portal/main.dart';

class UserModel extends ChangeNotifier{
  FirebaseAuth? auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn =
  GoogleSignIn(scopes: <String>['email'], clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);

  UserT? _currentUser;
  ImageProvider _profilePic = const AssetImage("assets/blank-profile-picture.png");
  Iterable<UserT>? _friends;

  Iterable<UserT>? get friends => _friends;
  set friends(Iterable<UserT>? f) {
    _friends = f;
    notifyListeners();
  }

  ImageProvider get profilePic => _profilePic;
  set profilePic(ImageProvider p) {
    _profilePic = p;
    notifyListeners();
  }

  UserModel() {
    auth!.authStateChanges().listen((User? user) {
      if (user != null) {
        db.collection("users").doc(user.uid).get().then((userDoc) {
          if (userDoc.exists) {
            currentUser = UserT.fromEntry(userDoc.data()!);
          } else {
            var u = UserT(
              username: user.email!,
              displayName: user.displayName,
              id: user.uid,
              friends: {},
              friendRequests: {},
            );
            db.collection("users").doc(u.id).set(u.toEntry());
            currentUser = u;
          }
        });
      } else {
        notifyListeners();
      }
    });
  }

  UserT? get currentUser => _currentUser;
  set currentUser(UserT? u) {
    _currentUser = u;
    notifyListeners();
    _getFriends();
    _getProfilePic();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await auth!.signInWithCredential(credential);
  }

  Future<void> signOutWithGoogle() async {
    googleSignIn.signOut();
    auth!.signOut();
  }

  Future<void> handleSignIn() async {
    try {
      await signInWithGoogle();
    } catch (error) {
      dev.log("Error during sign-in $error");
    }
  }

  Future<void> handleSignOut() async {
    signOutWithGoogle();
    currentUser = null;
    notifyListeners();
  }

  Future<void> _getProfilePic() async {
    try {
      profilePic = NetworkImage(
          await storage.child("users").child(currentUser!.id).child("profile_picture.jpg").getDownloadURL());
    } catch (e) {
      profilePic = const AssetImage("assets/blank-profile-picture.png");
    }
  }

  saveProfilePic(XFile img) async {
    storage
        .child("users")
        .child(currentUser!.id)
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
          _getProfilePic();
          break;
        case TaskState.canceled:
          dev.log("PP upload cancelled");
          break;
        case TaskState.error:
          dev.log("PP upload error");
          break;
      }
    });
  }

  void _getFriends() {
    Future.wait(currentUser!.friends.map((
        friendRef) => friendRef.get())).then((friendsList) {
          friends = friendsList.map((friend) {
            var friend_ = UserT.fromEntry(friend.data()!);
            return friend_;
          });
        });
  }

  void sendFriendRequest(UserT user) {
    user.ref.update({"friendRequests": currentUser?.ref});
  }

  void acceptRequest(UserT user) {
    addFriend(user);
    currentUser?.ref.update({"friendRequests": currentUser?.friendRequests.remove(user.ref)}).then((_) => notifyListeners());
  }

  void rejectRequest(UserT user) {
    currentUser?.ref.update({"friendRequests": currentUser?.friendRequests.remove(user.ref)}).then((_) => notifyListeners());
  }

  void addFriend(UserT user) {
    currentUser?.ref.update({"friends": currentUser?.friends.add(user.ref)});
    user.ref.update({"friends": user.friends.add(currentUser!.ref)});
  }

  void removeFriend(UserT user) {
    currentUser?.ref.update({"friends": currentUser?.friends.remove(user.ref)});
    user.ref.update({"friends": user.friends.remove(currentUser!.ref)});
  }
}