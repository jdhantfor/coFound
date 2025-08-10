import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/company.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/subscription.dart';
import '../models/business_card.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cofound.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица пользователей
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT,
        phone TEXT,
        position TEXT,
        company_name TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Таблица компаний
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        industry TEXT NOT NULL,
        location TEXT NOT NULL,
        logo_url TEXT,
        employee_count INTEGER NOT NULL,
        contact_email TEXT NOT NULL,
        created_by INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Таблица постов
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        company_id INTEGER,
        content TEXT NOT NULL,
        image_url TEXT,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (company_id) REFERENCES companies (id)
      )
    ''');

    // Таблица комментариев
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Таблица лайков
    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(post_id, user_id)
      )
    ''');

    // Таблица визиток
    await db.execute('''
      CREATE TABLE business_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        company_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        social_media_link TEXT,
        qr_code_data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Таблица подписок
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        plan_type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ ПОЛЬЗОВАТЕЛЕЙ ====================

  Future<int> insertUser(User user) async {
    final db = await database;
    final Map<String, dynamic> data = Map<String, dynamic>.from(user.toJson());
    // Локальная БД не хранит пароли, подставляем пустую строку для NOT NULL
    data['password_hash'] = data['password_hash'] ?? '';
    return await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ КОМПАНИЙ ====================

  Future<int> insertCompany(Company company) async {
    final db = await database;
    return await db.insert(
      'companies',
      company.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Company>> getAllCompanies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('companies');
    return List.generate(maps.length, (i) => Company.fromJson(maps[i]));
  }

  Future<Company?> getCompany(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Company.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateCompany(Company company) async {
    final db = await database;
    return await db.update(
      'companies',
      company.toJson(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  Future<int> deleteCompany(int id) async {
    final db = await database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ ПОСТОВ ====================

  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert(
      'posts',
      post.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Post.fromJson(maps[i]));
  }

  Future<Post?> getPost(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Post.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updatePost(Post post) async {
    final db = await database;
    return await db.update(
      'posts',
      post.toJson(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ КОММЕНТАРИЕВ ====================

  Future<int> insertComment(Comment comment) async {
    final db = await database;
    final result = await db.insert(
      'comments',
      comment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Обновляем счетчик комментариев в посте
    await db.rawUpdate('''
      UPDATE posts 
      SET comments_count = comments_count + 1 
      WHERE id = ?
    ''', [comment.postId]);
    
    return result;
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => Comment.fromJson(maps[i]));
  }

  Future<int> deleteComment(int id) async {
    final db = await database;
    final comment = await db.query(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (comment.isNotEmpty) {
      final postId = comment.first['post_id'];
      await db.rawUpdate('''
        UPDATE posts 
        SET comments_count = comments_count - 1 
        WHERE id = ?
      ''', [postId]);
    }
    
    return await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ ЛАЙКОВ ====================

  Future<int> insertLike(int postId, int userId) async {
    final db = await database;
    final result = await db.insert(
      'likes',
      {
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Обновляем счетчик лайков в посте
    await db.rawUpdate('''
      UPDATE posts 
      SET likes_count = likes_count + 1 
      WHERE id = ?
    ''', [postId]);
    
    return result;
  }

  Future<bool> isPostLikedByUser(int postId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
    return maps.isNotEmpty;
  }

  Future<int> removeLike(int postId, int userId) async {
    final db = await database;
    final result = await db.delete(
      'likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );
    
    // Обновляем счетчик лайков в посте
    await db.rawUpdate('''
      UPDATE posts 
      SET likes_count = likes_count - 1 
      WHERE id = ?
    ''', [postId]);
    
    return result;
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ ВИЗИТОК ====================

  Future<int> insertBusinessCard(BusinessCard card) async {
    final db = await database;
    return await db.insert(
      'business_cards',
      card.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BusinessCard>> getBusinessCardsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'business_cards',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => BusinessCard.fromJson(maps[i]));
  }

  Future<BusinessCard?> getBusinessCard(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'business_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return BusinessCard.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateBusinessCard(BusinessCard card) async {
    final db = await database;
    return await db.update(
      'business_cards',
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteBusinessCard(int id) async {
    final db = await database;
    return await db.delete(
      'business_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== CRUD ОПЕРАЦИИ ДЛЯ ПОДПИСОК ====================

  Future<int> insertSubscription(Subscription subscription) async {
    final db = await database;
    return await db.insert(
      'subscriptions',
      subscription.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Subscription?> getActiveSubscription(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Subscription.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateSubscription(Subscription subscription) async {
    final db = await database;
    return await db.update(
      'subscriptions',
      subscription.toJson(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'cofound.db');
    await databaseFactory.deleteDatabase(dbPath);
  }
} 