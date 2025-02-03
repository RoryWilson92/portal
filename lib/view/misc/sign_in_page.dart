import 'package:flutter/material.dart';
import 'package:portal/model/user_model.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {

  const SignInPage({super.key});

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
          children: <Widget>[
            Text('You are not currently signed in.'),
            ElevatedButton(
              onPressed: context.read<UserModel>().handleSignIn,
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
      ),
    );
  }
}
