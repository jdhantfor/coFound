import '../models/business_card.dart';
import '../services/business_card_service.dart';

class BusinessCardRepository {
  final BusinessCardService _businessCardService = BusinessCardService();

  // ==================== ОСНОВНЫЕ ОПЕРАЦИИ ====================

  Future<List<BusinessCard>> getBusinessCardsForUser(int userId) async {
    return await _businessCardService.getBusinessCardsForUser(userId);
  }

  Future<BusinessCard?> getBusinessCard(int id) async {
    return await _businessCardService.getBusinessCard(id);
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
    return await _businessCardService.createBusinessCard(
      userId: userId,
      name: name,
      position: position,
      companyName: companyName,
      phone: phone,
      email: email,
      socialMediaLink: socialMediaLink,
    );
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
    return await _businessCardService.updateBusinessCard(
      cardId: cardId,
      name: name,
      position: position,
      companyName: companyName,
      phone: phone,
      email: email,
      socialMediaLink: socialMediaLink,
    );
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<BusinessCard?> getCurrentUserBusinessCard(int userId) async {
    return await _businessCardService.getCurrentUserBusinessCard(userId);
  }

  Future<String> generateQRCodeData(int userId) async {
    return await _businessCardService.generateQRCodeData(userId);
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
    return await _businessCardService.createOrUpdateBusinessCard(
      userId: userId,
      name: name,
      position: position,
      companyName: companyName,
      phone: phone,
      email: email,
      socialMediaLink: socialMediaLink,
    );
  }

  Future<void> refreshBusinessCards(int userId) async {
    await _businessCardService.refreshBusinessCards(userId);
  }

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<BusinessCard>> getLocalBusinessCardsForUser(int userId) async {
    return await _businessCardService.getLocalBusinessCardsForUser(userId);
  }

  Future<BusinessCard?> getLocalBusinessCard(int id) async {
    return await _businessCardService.getLocalBusinessCard(id);
  }

  Future<int> saveBusinessCardLocally(BusinessCard card) async {
    return await _businessCardService.saveBusinessCardLocally(card);
  }

  Future<int> updateBusinessCardLocally(BusinessCard card) async {
    return await _businessCardService.updateBusinessCardLocally(card);
  }
} 