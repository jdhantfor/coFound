import '../models/user.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _userService = UserService();

  // ==================== ОСНОВНЫЕ ОПЕРАЦИИ ====================

  Future<User?> registerUser({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? position,
    String? companyName,
  }) async {
    return await _userService.registerUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      position: position,
      companyName: companyName,
    );
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    return await _userService.loginUser(
      email: email,
      password: password,
    );
  }

  Future<User?> getUser(int id) async {
    return await _userService.getUser(id);
  }

  Future<bool> updateUser({
    required int userId,
    String? name,
    String? phone,
    String? position,
    String? companyName,
    String? avatarUrl,
  }) async {
    return await _userService.updateUser(
      userId: userId,
      name: name,
      phone: phone,
      position: position,
      companyName: companyName,
      avatarUrl: avatarUrl,
    );
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<User?> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  Future<bool> isUserLoggedIn() async {
    return await _userService.isUserLoggedIn();
  }

  Future<void> logout() async {
    await _userService.logout();
  }

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<User?> getLocalUser(int id) async {
    return await _userService.getLocalUser(id);
  }

  Future<User?> getLocalUserByEmail(String email) async {
    return await _userService.getLocalUserByEmail(email);
  }

  Future<int> saveUserLocally(User user) async {
    return await _userService.saveUserLocally(user);
  }

  Future<int> updateUserLocally(User user) async {
    return await _userService.updateUserLocally(user);
  }
} 