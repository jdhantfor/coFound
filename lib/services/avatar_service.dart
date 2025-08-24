import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const String _avatarKey = 'user_avatar_path';
  static const String _avatarUrlKey = 'user_avatar_url';
  
  static final ImagePicker _picker = ImagePicker();

  /// Получить аватар из галереи
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Ошибка при выборе изображения из галереи: $e');
      return null;
    }
  }

  /// Сделать фото с камеры
  static Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Ошибка при съемке фото: $e');
      return null;
    }
  }

  /// Сохранить аватар локально
  static Future<String?> saveAvatarLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${directory.path}/avatars');
      
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('${avatarDir.path}/$fileName');
      
      await imageFile.copy(savedFile.path);
      
      // Сохраняем путь в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, savedFile.path);
      
      return savedFile.path;
    } catch (e) {
      print('Ошибка при сохранении аватара: $e');
      return null;
    }
  }

  /// Получить локальный путь к аватару
  static Future<String?> getLocalAvatarPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatarPath = prefs.getString(_avatarKey);
      
      if (avatarPath != null) {
        final file = File(avatarPath);
        if (await file.exists()) {
          return avatarPath;
        }
      }
      return null;
    } catch (e) {
      print('Ошибка при получении пути к аватару: $e');
      return null;
    }
  }

  /// Загрузить аватар на сервер
  static Future<String?> uploadAvatarToServer(File imageFile, int userId) async {
    try {
      final url = Uri.parse('http://62.113.37.96:8000/upload_avatar');
      
      final request = http.MultipartRequest('POST', url);
      request.fields['user_id'] = userId.toString();
      
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'avatar',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        final avatarUrl = data['avatar_url'];
        
        if (avatarUrl != null) {
          // Сохраняем URL аватара
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_avatarUrlKey, avatarUrl);
          return avatarUrl;
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка при загрузке аватара на сервер: $e');
      return null;
    }
  }

  /// Получить URL аватара с сервера
  static Future<String?> getAvatarUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatarUrlKey);
    } catch (e) {
      print('Ошибка при получении URL аватара: $e');
      return null;
    }
  }

  /// Удалить аватар
  static Future<void> deleteAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Удаляем локальный файл
      final localPath = prefs.getString(_avatarKey);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Очищаем сохраненные данные
      await prefs.remove(_avatarKey);
      await prefs.remove(_avatarUrlKey);
    } catch (e) {
      print('Ошибка при удалении аватара: $e');
    }
  }

  /// Создать круглый аватар виджет
  static Widget buildAvatarWidget({
    required double radius,
    String? localPath,
    String? networkUrl,
    Widget? placeholder,
    Color? backgroundColor,
  }) {
    if (localPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        backgroundImage: FileImage(File(localPath)),
        child: placeholder,
      );
    } else if (networkUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        backgroundImage: NetworkImage(networkUrl),
        child: placeholder,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: placeholder ?? const Icon(Icons.person, color: Colors.grey),
      );
    }
  }
}
