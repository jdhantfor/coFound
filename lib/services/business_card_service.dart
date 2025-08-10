import 'package:dio/dio.dart';
import '../models/business_card.dart';
import 'database_helper.dart';

class BusinessCardService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Dio _dio = Dio();
  final String _baseUrl = 'http://62.113.37.96:8000';

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<BusinessCard>> getLocalBusinessCardsForUser(int userId) async {
    return await _databaseHelper.getBusinessCardsForUser(userId);
  }

  Future<BusinessCard?> getLocalBusinessCard(int id) async {
    return await _databaseHelper.getBusinessCard(id);
  }

  Future<int> saveBusinessCardLocally(BusinessCard card) async {
    return await _databaseHelper.insertBusinessCard(card);
  }

  Future<int> updateBusinessCardLocally(BusinessCard card) async {
    return await _databaseHelper.updateBusinessCard(card);
  }

  // ==================== СЕТЕВЫЕ ОПЕРАЦИИ ====================

  Future<List<BusinessCard>> getBusinessCardsForUser(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl/business-cards/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> cardsData = response.data;
        final List<BusinessCard> cards = cardsData.map((json) => BusinessCard.fromJson(json)).toList();

        // Сохраняем визитки локально
        for (final card in cards) {
          await saveBusinessCardLocally(card);
        }

        return cards;
      }
    } catch (e) {
      print('Ошибка получения визиток: $e');
      // Возвращаем локальные данные
      return await getLocalBusinessCardsForUser(userId);
    }
    return [];
  }

  Future<BusinessCard?> createBusinessCard({
    required int userId,
    required String name,
    required String position,
    required String companyName,
    required String phone,
    required String email,
    String? socialMediaLink,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/business-cards',
        data: {
          'name': name,
          'position': position,
          'company_name': companyName,
          'phone': phone,
          'email': email,
          'social_media_link': socialMediaLink,
        },
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final cardId = response.data['card_id'];
        final card = BusinessCard(
          id: cardId,
          userId: userId,
          name: name,
          position: position,
          companyName: companyName,
          phone: phone,
          email: email,
          socialMediaLink: socialMediaLink,
          qrCodeData: 'https://cofound.app/users/$userId',
          createdAt: DateTime.now(),
        );

        // Сохраняем визитку локально
        await saveBusinessCardLocally(card);
        return card;
      }
    } catch (e) {
      print('Ошибка создания визитки: $e');
      rethrow;
    }
    return null;
  }

  Future<BusinessCard?> getBusinessCard(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/business-cards/$id');

      if (response.statusCode == 200) {
        final card = BusinessCard.fromJson(response.data);
        
        // Сохраняем визитку локально
        await saveBusinessCardLocally(card);
        return card;
      }
    } catch (e) {
      print('Ошибка получения визитки: $e');
      // Пробуем получить из локальной БД
      return await getLocalBusinessCard(id);
    }
    return null;
  }

  Future<bool> updateBusinessCard({
    required int cardId,
    String? name,
    String? position,
    String? companyName,
    String? phone,
    String? email,
    String? socialMediaLink,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/business-cards/$cardId',
        data: {
          if (name != null) 'name': name,
          if (position != null) 'position': position,
          if (companyName != null) 'company_name': companyName,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (socialMediaLink != null) 'social_media_link': socialMediaLink,
        },
      );

      if (response.statusCode == 200) {
        // Обновляем локальную копию
        final localCard = await getLocalBusinessCard(cardId);
        if (localCard != null) {
          final updatedCard = localCard.copyWith(
            name: name,
            position: position,
            companyName: companyName,
            phone: phone,
            email: email,
            socialMediaLink: socialMediaLink,
          );
          await updateBusinessCardLocally(updatedCard);
        }
        return true;
      }
    } catch (e) {
      print('Ошибка обновления визитки: $e');
      return false;
    }
    return false;
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

  Future<BusinessCard?> getCurrentUserBusinessCard(int userId) async {
    final cards = await getBusinessCardsForUser(userId);
    if (cards.isNotEmpty) {
      return cards.first;
    }
    return null;
  }

  Future<String> generateQRCodeData(int userId) async {
    return 'https://cofound.app/users/$userId';
  }

  Future<BusinessCard?> createOrUpdateBusinessCard({
    required int userId,
    required String name,
    required String position,
    required String companyName,
    required String phone,
    required String email,
    String? socialMediaLink,
  }) async {
    // Проверяем, есть ли уже визитка у пользователя
    final existingCard = await getCurrentUserBusinessCard(userId);
    
    if (existingCard != null) {
      // Обновляем существующую визитку
      final success = await updateBusinessCard(
        cardId: existingCard.id,
        name: name,
        position: position,
        companyName: companyName,
        phone: phone,
        email: email,
        socialMediaLink: socialMediaLink,
      );
      
      if (success) {
        return await getBusinessCard(existingCard.id);
      }
    } else {
      // Создаем новую визитку
      return await createBusinessCard(
        userId: userId,
        name: name,
        position: position,
        companyName: companyName,
        phone: phone,
        email: email,
        socialMediaLink: socialMediaLink,
      );
    }
    
    return null;
  }

  Future<void> refreshBusinessCards(int userId) async {
    // Обновляем визитки с сервера
    await getBusinessCardsForUser(userId);
  }

  // ==================== ИЗБРАННОЕ ====================

  Future<List<BusinessCard>> getFavorites(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl/favorites/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> cardsData = response.data;
        final List<BusinessCard> cards = cardsData.map((json) => BusinessCard.fromJson(json)).toList();
        // Кэшируем локально
        for (final c in cards) {
          await saveBusinessCardLocally(c);
        }
        return cards;
      }
    } catch (e) {
      print('Ошибка получения избранного: $e');
    }
    return [];
  }

  Future<bool> addToFavorites({required int userId, required int businessCardId}) async {
    try {
      final response = await _dio.post('$_baseUrl/favorites',
          queryParameters: {'user_id': userId},
          data: {'business_card_id': businessCardId});
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка добавления в избранное: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites({required int userId, required int businessCardId}) async {
    try {
      final response = await _dio.delete('$_baseUrl/favorites',
          queryParameters: {
            'user_id': userId,
            'business_card_id': businessCardId,
          });
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка удаления из избранного: $e');
      return false;
    }
  }
} 