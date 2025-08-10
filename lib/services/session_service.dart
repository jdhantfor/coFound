import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyCurrentUserId = 'current_user_id';

  static Future<void> setCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentUserId, userId);
  }

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentUserId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
  }
}


