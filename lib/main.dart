import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '/misc/sign_in_page.dart';
import '/util/firebase_options.dart';
import '/util/types.dart';

UserT? _currentUser;
final db = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();
FirebaseAuth? auth = FirebaseAuth.instance;

void setCurrentUser(UserT u) {
  _currentUser = u;
}

UserT? getCurrentUser() {
  return _currentUser;
}

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
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: ThemeColors.primaryContrast,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: "Product Sans",
            color: ThemeColors.accent,
            fontSize: 36,
          ),
          iconTheme: const IconThemeData(color: ThemeColors.accent),
        ),
        iconTheme: const IconThemeData(color: ThemeColors.accent),
        fontFamily: "Product Sans",
        scaffoldBackgroundColor: ThemeColors.primary,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: ThemeColors.textOnPrimary,
            fontSize: 18,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ThemeColors.accent,
          selectionHandleColor: ThemeColors.accent,
          selectionColor: ThemeColors.opacity(ThemeColors.accent, 0.4),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: ThemeColors.primary,
          titleTextStyle: const TextStyle(
            fontFamily: "Product Sans",
            color: ThemeColors.textOnPrimary,
            fontSize: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(10),
          hintStyle: TextStyle(color: ThemeColors.darker(ThemeColors.textOnPrimary)),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: ThemeColors.accent),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.accent,
            textStyle: const TextStyle(
              fontFamily: "Product Sans",
              fontSize: 28,
            ),
            foregroundColor: ThemeColors.textOnAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ThemeColors.accent,
          iconSize: 32,
          foregroundColor: ThemeColors.textOnAccent,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: ThemeColors.primary,
          unselectedItemColor: ThemeColors.textOnPrimary,
          selectedItemColor: ThemeColors.accent,
        ),
        dividerTheme: DividerThemeData(
          color: ThemeColors.darker(ThemeColors.textOnPrimary, degree: 3),
          indent: 10,
          endIndent: 10,
          thickness: 0.5,
          space: 20,
        ),
      ),
      home: const SignInPage(),
    );
  }
}
