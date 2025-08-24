import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLastLoginTime = 'last_login_time';

  static Future<void> setCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyLastLoginTime, DateTime.now().toIso8601String());
  }

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentUserId);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserEmail, email);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  static Future<DateTime?> getLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_keyLastLoginTime);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyLastLoginTime);
  }

  static Future<void> logout() async {
    await clear();
  }
}


