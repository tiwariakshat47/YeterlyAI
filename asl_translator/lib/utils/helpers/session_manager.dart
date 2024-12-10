import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'secure_storage.dart';

class SessionManager {
  static const String _firstLaunchKey = 'first_launch';
  static const String _agreementKey = 'agreement_accepted';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = !prefs.containsKey(_firstLaunchKey);
    if (isFirst) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    return isFirst;
  }

  static Future<void> clearSession() async {
    await FirebaseAuth.instance.signOut();
    await SecureStorage.clearCredentials();
  }

  static Future<bool> needsAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_agreementKey) ?? false);
  }
}
