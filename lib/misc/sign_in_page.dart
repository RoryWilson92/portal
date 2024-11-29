import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/misc/page_holder.dart';
import '../main.dart';
import '/util/firebase_options.dart';
import '/util/types.dart';
import 'dart:developer' as dev;

GoogleSignIn googleSignIn =
    GoogleSignIn(scopes: <String>['email'], clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);

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

Future<void> _handleSignIn() async {
  try {
    await signInWithGoogle();
  } catch (error) {
    dev.log("Error during sign-in $error");
  }
}

Future<void> handleSignOut() async {
  signOutWithGoogle();
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State createState() => _SignInPageState();
}

class _SignInPage extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign In"),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const <Widget>[
              Text('You are not currently signed in.'),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("Sign In"),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();
    auth!.authStateChanges().listen((User? user) {
      if (user != null) {
        var u = UserT(
          username: user.email!,
          displayName: user.displayName,
          id: user.uid,
        );
        db.collection("users").doc(u.id).set(u.toEntry());
        setCurrentUser(u);
        setState(() {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PageHolder()));
        });
      }
    });
    // _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign In"),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const <Widget>[
              Text('You are not currently signed in.'),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text("Sign In"),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
