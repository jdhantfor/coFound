import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/business_card.dart';
import '../models/post.dart';
import '../models/company.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  // Stream controllers for different data types
  final StreamController<User> _userUpdateController = StreamController<User>.broadcast();
  final StreamController<BusinessCard> _businessCardUpdateController = StreamController<BusinessCard>.broadcast();
  final StreamController<Post> _postUpdateController = StreamController<Post>.broadcast();
  final StreamController<Company> _companyUpdateController = StreamController<Company>.broadcast();

  // Streams for listening to updates
  Stream<User> get userUpdates => _userUpdateController.stream;
  Stream<BusinessCard> get businessCardUpdates => _businessCardUpdateController.stream;
  Stream<Post> get postUpdates => _postUpdateController.stream;
  Stream<Company> get companyUpdates => _companyUpdateController.stream;

  // Cache for storing data
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Cache expiration time (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // ==================== USER UPDATES ====================

  void notifyUserUpdate(User user) {
    _userUpdateController.add(user);
    _updateCache('user_${user.id}', user);
    _logChange('User updated: ${user.name}');
  }

  void notifyUserCreated(User user) {
    _userUpdateController.add(user);
    _updateCache('user_${user.id}', user);
    _logChange('User created: ${user.name}');
  }

  // ==================== BUSINESS CARD UPDATES ====================

  void notifyBusinessCardUpdate(BusinessCard card) {
    _businessCardUpdateController.add(card);
    _updateCache('business_card_${card.id}', card);
    _logChange('Business card updated: ${card.name}');
  }

  void notifyBusinessCardCreated(BusinessCard card) {
    _businessCardUpdateController.add(card);
    _updateCache('business_card_${card.id}', card);
    _logChange('Business card created: ${card.name}');
  }

  // ==================== POST UPDATES ====================

  void notifyPostUpdate(Post post) {
    _postUpdateController.add(post);
    _updateCache('post_${post.id}', post);
    _logChange('Post updated: ${post.content.substring(0, post.content.length > 30 ? 30 : post.content.length)}...');
  }

  void notifyPostCreated(Post post) {
    _postUpdateController.add(post);
    _updateCache('post_${post.id}', post);
    _logChange('Post created: ${post.content.substring(0, post.content.length > 30 ? 30 : post.content.length)}...');
  }

  // ==================== COMPANY UPDATES ====================

  void notifyCompanyUpdate(Company company) {
    _companyUpdateController.add(company);
    _updateCache('company_${company.id}', company);
    _logChange('Company updated: ${company.name}');
  }

  void notifyCompanyCreated(Company company) {
    _companyUpdateController.add(company);
    _updateCache('company_${company.id}', company);
    _logChange('Company created: ${company.name}');
  }

  // ==================== CACHE MANAGEMENT ====================

  void _updateCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _logChange('Cache cleared');
  }

  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiration)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logChange('Cleared ${expiredKeys.length} expired cache entries');
    }
  }

  // ==================== BATCH UPDATES ====================

  void notifyBatchUpdate({
    List<User>? users,
    List<BusinessCard>? businessCards,
    List<Post>? posts,
    List<Company>? companies,
  }) {
    if (users != null) {
      for (final user in users) {
        notifyUserUpdate(user);
      }
    }

    if (businessCards != null) {
      for (final card in businessCards) {
        notifyBusinessCardUpdate(card);
      }
    }

    if (posts != null) {
      for (final post in posts) {
        notifyPostUpdate(post);
      }
    }

    if (companies != null) {
      for (final company in companies) {
        notifyCompanyUpdate(company);
      }
    }

    _logChange('Batch update completed');
  }

  // ==================== LOGGING ====================

  void _logChange(String message) {
    if (kDebugMode) {
      print('SyncService: $message');
    }
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _userUpdateController.close();
    _businessCardUpdateController.close();
    _postUpdateController.close();
    _companyUpdateController.close();
    super.dispose();
  }

  // ==================== UTILITY METHODS ====================

  bool hasRecentUpdate(String key, {Duration? threshold}) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final timeThreshold = threshold ?? const Duration(minutes: 1);
    return DateTime.now().difference(timestamp) < timeThreshold;
  }

  DateTime? getLastUpdateTime(String key) {
    return _cacheTimestamps[key];
  }

  List<String> getCacheKeys() {
    return _cache.keys.toList();
  }

  int getCacheSize() {
    return _cache.length;
  }
} 