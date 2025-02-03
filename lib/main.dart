import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:portal/model/user_model.dart';
import 'package:portal/theme/app_theme.dart';
import 'package:portal/view/misc/page_holder.dart';
import 'package:portal/view/misc/sign_in_page.dart';
import 'package:portal/util/firebase_options.dart';
import 'package:provider/provider.dart';

final db = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MoreLife",
      theme: AppTheme.appThemeData,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (BuildContext context) => UserModel()),
        ],
        child: Consumer<UserModel>(
          builder: (context, userModel, child) {
            return userModel.currentUser == null ? const SignInPage() : PageHolder();
          },
        ),
      ),
    );
  }
}
