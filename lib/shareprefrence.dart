import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const _userUidKey = 'user_uid';
  static const _userEmailKey = 'user_email';

  // Save User UID
  static Future<void> saveUserUid(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userUidKey, uid);
  }

  // Get User UID
  static Future<String?> getUserUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userUidKey);
  }

  // Remove User UID
  static Future<void> removeUserUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userUidKey);
  }

  // Save User Email
  static Future<void> saveUserEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Get User Email
  static Future<String?> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Remove User Email
  static Future<void> removeUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
  }
}

