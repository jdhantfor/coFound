import 'package:dio/dio.dart';
import '../models/user.dart';
import 'database_helper.dart';

class UserService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Dio _dio = Dio();
  final String _baseUrl = 'http://62.113.37.96:8000'; // Замените на ваш URL сервера

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<User?> getLocalUser(int id) async {
    return await _databaseHelper.getUser(id);
  }

  Future<User?> getLocalUserByEmail(String email) async {
    return await _databaseHelper.getUserByEmail(email);
  }

  Future<int> saveUserLocally(User user) async {
    return await _databaseHelper.insertUser(user);
  }

  Future<int> updateUserLocally(User user) async {
    return await _databaseHelper.updateUser(user);
  }

  // ==================== СЕТЕВЫЕ ОПЕРАЦИИ ====================

  Future<User?> registerUser({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? position,
    String? companyName,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'position': position,
          'company_name': companyName,
        },
      );

      if (response.statusCode == 200) {
        final userId = response.data['user_id'];
        final user = User(
          id: userId,
          email: email,
          name: name,
          phone: phone,
          position: position,
          companyName: companyName,
          createdAt: DateTime.now(),
        );

        // Сохраняем пользователя локально
        await saveUserLocally(user);
        return user;
      }
    } catch (e) {
      print('Ошибка регистрации: $e');
      rethrow;
    }
    return null;
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final userId = response.data['user_id'];
        return await getUser(userId);
      }
    } catch (e) {
      print('Ошибка входа: $e');
      rethrow;
    }
    return null;
  }

  Future<User?> getUser(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/users/$id');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        
        // Сохраняем пользователя локально
        await saveUserLocally(user);
        return user;
      }
    } catch (e) {
      print('Ошибка получения пользователя: $e');
      // Пробуем получить из локальной БД
      return await getLocalUser(id);
    }
    return null;
  }

  Future<bool> updateUser({
    required int userId,
    String? email,
    String? name,
    String? phone,
    String? position,
    String? companyName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/users/$userId',
        data: {
          if (email != null) 'email': email,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (position != null) 'position': position,
          if (companyName != null) 'company_name': companyName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );

      if (response.statusCode == 200) {
        // Обновляем локальную копию
        final localUser = await getLocalUser(userId);
        if (localUser != null) {
          final updatedUser = localUser.copyWith(
            email: email,
            name: name,
            phone: phone,
            position: position,
            companyName: companyName,
            avatarUrl: avatarUrl,
          );
          await updateUserLocally(updatedUser);
        }
        return true;
      }
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      return false;
    }
    return false;
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

  Future<bool> isUserLoggedIn() async {
    // Проверяем наличие пользователя в локальной БД
    // В реальном приложении здесь должна быть проверка токена
    return true;
  }

  Future<void> logout() async {
    // Очищаем локальные данные пользователя
    // В реальном приложении здесь должна быть очистка токена
  }

  Future<User?> getCurrentUser() async {
    // Получаем текущего пользователя из локальной БД
    // В реальном приложении здесь должна быть проверка токена
    return null;
  }
} 