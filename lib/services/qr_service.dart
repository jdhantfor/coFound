import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';  // Temporarily disabled
// import 'package:path_provider/path_provider.dart';  // Temporarily disabled
import 'package:permission_handler/permission_handler.dart';
import '/models/user.dart';
import '/models/business_card.dart';
import '/models/subscription.dart';

class QRService {
  // ==================== ГЕНЕРАЦИЯ QR-КОДОВ ====================

  /// Генерирует QR-код для визитки пользователя
  static Widget generateBusinessCardQR({
    required BusinessCard card,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final qrData = _createBusinessCardData(card);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      embeddedImage: const AssetImage('assets/icon.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(40, 40),
      ),
    );
  }

  /// Генерирует QR-код для подписки
  static Widget generateSubscriptionQR({
    required Subscription subscription,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final qrData = _createSubscriptionData(subscription);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      embeddedImage: const AssetImage('assets/icon.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(40, 40),
      ),
    );
  }

  /// Генерирует QR-код для пользователя
  static Widget generateUserQR({
    required User user,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final qrData = _createUserData(user);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      embeddedImage: const AssetImage('assets/icon.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(40, 40),
      ),
    );
  }

  // ==================== СОХРАНЕНИЕ QR-КОДОВ ====================

  /// Сохраняет QR-код в галерею
  static Future<bool> saveQRToGallery({
    required Widget qrWidget,
    required String fileName,
  }) async {
    try {
      // Запрашиваем разрешение на доступ к галерее
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Разрешение на доступ к галерее не предоставлено');
      }

      // TODO: Реализовать сохранение в галерею после исправления зависимости image_gallery_saver
      // Временно возвращаем false
      print('Сохранение в галерею временно недоступно из-за проблем с зависимостью image_gallery_saver');
      return false;
    } catch (e) {
      print('Ошибка сохранения QR-кода: $e');
      return false;
    }
  }

  /// Сохраняет QR-код визитки в галерею
  static Future<bool> saveBusinessCardQR({
    required BusinessCard card,
    double size = 300,
  }) async {
    final qrWidget = generateBusinessCardQR(
      card: card,
      size: size,
    );

    final fileName = 'cofound_card_${card.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
    
    return await saveQRToGallery(
      qrWidget: qrWidget,
      fileName: fileName,
    );
  }

  /// Сохраняет QR-код подписки в галерею
  static Future<bool> saveSubscriptionQR({
    required Subscription subscription,
    double size = 300,
  }) async {
    final qrWidget = generateSubscriptionQR(
      subscription: subscription,
      size: size,
    );

    final fileName = 'cofound_subscription_${subscription.planType}_${DateTime.now().millisecondsSinceEpoch}.png';
    
    return await saveQRToGallery(
      qrWidget: qrWidget,
      fileName: fileName,
    );
  }

  // ==================== СКАНИРОВАНИЕ QR-КОДОВ ====================

  /// Обрабатывает отсканированные данные
  static QRScanResult processScannedData(String scannedData) {
    try {
      // Пытаемся декодировать JSON
      final Map<String, dynamic> data = json.decode(scannedData);
      
      final String type = data['type'] ?? '';
      
      switch (type) {
        case 'business_card':
          return QRScanResult.businessCard(
            BusinessCard.fromJson(data['data']),
          );
        
        case 'subscription':
          return QRScanResult.subscription(
            Subscription.fromJson(data['data']),
          );
        
        case 'user':
          return QRScanResult.user(
            User.fromJson(data['data']),
          );
        
        default:
          return QRScanResult.unknown(scannedData);
      }
    } catch (e) {
      // Если не JSON, проверяем URL
      if (scannedData.startsWith('http')) {
        return QRScanResult.url(scannedData);
      }
      
      // Иначе считаем обычным текстом
      return QRScanResult.text(scannedData);
    }
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ====================

  /// Создает данные для QR-кода визитки
  static String _createBusinessCardData(BusinessCard card) {
    final data = {
      'type': 'business_card',
      'data': {
        'id': card.id,
        'user_id': card.userId,
        'name': card.name,
        'position': card.position,
        'company_name': card.companyName,
        'phone': card.phone,
        'email': card.email,
        'social_media_link': card.socialMediaLink,
        'qr_code_data': card.qrCodeData,
        'created_at': card.createdAt.toIso8601String(),
      },
    };
    
    return json.encode(data);
  }

  /// Создает данные для QR-кода подписки
  static String _createSubscriptionData(Subscription subscription) {
    final data = {
      'type': 'subscription',
      'data': {
        'id': subscription.id,
        'userId': subscription.userId,
        'planType': subscription.planType,
        'startDate': subscription.startDate.toIso8601String(),
        'endDate': subscription.endDate?.toIso8601String(),
        'status': subscription.status,
      },
    };
    
    return json.encode(data);
  }

  /// Создает данные для QR-кода пользователя
  static String _createUserData(User user) {
    final data = {
      'type': 'user',
      'data': {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'position': user.position,
        'companyName': user.companyName,
        'avatarUrl': user.avatarUrl,
        'createdAt': user.createdAt.toIso8601String(),
      },
    };
    
    return json.encode(data);
  }

  /// Конвертирует виджет в байты изображения
  static Future<Uint8List> _widgetToImageBytes(Widget widget) async {
    // Временная заглушка - в реальном приложении нужно использовать GlobalKey
    // для получения RenderRepaintBoundary из виджета
    throw UnimplementedError('Метод требует доработки с использованием GlobalKey');
  }
}

// ==================== МОДЕЛЬ РЕЗУЛЬТАТА СКАНИРОВАНИЯ ====================

class QRScanResult {
  final QRScanType type;
  final dynamic data;

  QRScanResult._(this.type, this.data);

  factory QRScanResult.businessCard(BusinessCard card) {
    return QRScanResult._(QRScanType.businessCard, card);
  }

  factory QRScanResult.subscription(Subscription subscription) {
    return QRScanResult._(QRScanType.subscription, subscription);
  }

  factory QRScanResult.user(User user) {
    return QRScanResult._(QRScanType.user, user);
  }

  factory QRScanResult.url(String url) {
    return QRScanResult._(QRScanType.url, url);
  }

  factory QRScanResult.text(String text) {
    return QRScanResult._(QRScanType.text, text);
  }

  factory QRScanResult.unknown(String data) {
    return QRScanResult._(QRScanType.unknown, data);
  }
}

enum QRScanType {
  businessCard,
  subscription,
  user,
  url,
  text,
  unknown,
} 