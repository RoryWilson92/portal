import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'secrets/keys.env')
final class Env {
  @EnviedField(varName: 'FIREBASE_WEB_KEY', obfuscate: true)
  static final String firebaseWebKey = _Env.firebaseWebKey;

  @EnviedField(varName: 'FIREBASE_IOS_KEY', obfuscate: true)
  static final String firebaseIosKey = _Env.firebaseIosKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_KEY', obfuscate: true)
  static final String firebaseAndroidKey = _Env.firebaseAndroidKey;
}