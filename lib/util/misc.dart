// import 'package:portal/model/types/user.dart';
//
// var rollo = const UserT(
//   username: "rollodyson",
//   displayName: "Rollo Kennedy-Dyson",
//   id: "0",
// );
// var angus = const UserT(
//   username: "angusgibby",
//   displayName: "Angus Gibby",
//   id: "1",
// );
// var josh = const UserT(
//   username: "joshfarmer",
//   displayName: "Josh Farmer",
//   id: "2",
// );

class SignInException implements Exception {
  String cause;

  SignInException(this.cause);
}

typedef Entry = Map<String, dynamic>;
