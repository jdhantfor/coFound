import '/models/models.dart';
import '/services/database_helper.dart';
import '/services/post_service.dart';
import '/services/user_service.dart';
import '/services/company_service.dart';
import 'package:dio/dio.dart';

class TestFeedData {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static final PostService _postService = PostService();
  static final UserService _userService = UserService();
  static final CompanyService _companyService = CompanyService();
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://62.113.37.96:8000';

  // ==================== ЛОКАЛЬНЫЕ ДАННЫЕ ====================

  static Future<void> insertTestData() async {
    try {
      // Создаем тестовых пользователей
      final user1 = User(
        id: 1,
        email: 'ivan@techstart.ru',
        name: 'Иван Иванов',
        phone: '+7 (999) 123-45-67',
        position: 'CEO',
        companyName: 'TechStart',
        avatarUrl: 'assets/avatar_ivan.svg',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final user2 = User(
        id: 2,
        email: 'anna@greeneco.ru',
        name: 'Анна Смирнова',
        phone: '+7 (999) 987-65-43',
        position: 'CTO',
        companyName: 'GreenEco',
        avatarUrl: 'assets/avatar_anna.svg',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      );

      final user3 = User(
        id: 3,
        email: 'pavel@eduplatform.ru',
        name: 'Павел Козлов',
        phone: '+7 (999) 555-44-33',
        position: 'Founder',
        companyName: 'EduPlatform',
        avatarUrl: 'assets/avatar_pavel.svg',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      );

      // Создаем тестовые компании
      final company1 = Company(
        id: 1,
        name: 'TechStart',
        description: 'Инновационная финтех-компания',
        industry: 'Финансы',
        location: 'Москва',
        logoUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=TS',
        employeeCount: 50,
        contactEmail: 'info@techstart.ru',
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final company2 = Company(
        id: 2,
        name: 'GreenEco',
        description: 'Экологичные решения для бизнеса',
        industry: 'Экология',
        location: 'Санкт-Петербург',
        logoUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=GE',
        employeeCount: 25,
        contactEmail: 'info@greeneco.ru',
        createdBy: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      );

      final company3 = Company(
        id: 3,
        name: 'EduPlatform',
        description: 'Онлайн-образование для всех',
        industry: 'Образование',
        location: 'Казань',
        logoUrl: 'https://via.placeholder.com/100/2196F3/FFFFFF?text=EP',
        employeeCount: 15,
        contactEmail: 'info@eduplatform.ru',
        createdBy: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      );

      // Сохраняем пользователей
      await _dbHelper.insertUser(user1);
      await _dbHelper.insertUser(user2);
      await _dbHelper.insertUser(user3);

      // Сохраняем компании
      await _dbHelper.insertCompany(company1);
      await _dbHelper.insertCompany(company2);
      await _dbHelper.insertCompany(company3);

      // Создаем тестовые посты
      final post1 = Post(
        id: 1,
        userId: 1,
        companyId: 1,
        content: 'Запустили новый финтех-продукт! Ищем партнеров для масштабирования. Наша платформа поможет малому бизнесу оптимизировать финансовые процессы.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Финтех+Продукт',
        likesCount: 24,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final post2 = Post(
        id: 2,
        userId: 2,
        companyId: 2,
        content: 'Открыли новый центр переработки в Санкт-Петербурге! Присоединяйтесь к нашей миссии по созданию экологичного будущего.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Центр+Переработки',
        likesCount: 15,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final post3 = Post(
        id: 3,
        userId: 3,
        companyId: 3,
        content: 'Новый курс по Flutter уже доступен! Записывайтесь на платформе и станьте разработчиком мобильных приложений.',
        imageUrl: 'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Курс+Flutter',
        likesCount: 32,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      final post4 = Post(
        id: 4,
        userId: 1,
        companyId: 1,
        content: 'Провели успешную презентацию нашего продукта на конференции FinTech 2024. Получили много положительных отзывов!',
        imageUrl: null,
        likesCount: 18,
        commentsCount: 4,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      );

      final post5 = Post(
        id: 5,
        userId: 2,
        companyId: 2,
        content: 'Наша команда приняла участие в экологическом форуме. Обсудили перспективы развития зеленых технологий в России.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Эко+Форум',
        likesCount: 27,
        commentsCount: 6,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      // Сохраняем посты
      await _dbHelper.insertPost(post1);
      await _dbHelper.insertPost(post2);
      await _dbHelper.insertPost(post3);
      await _dbHelper.insertPost(post4);
      await _dbHelper.insertPost(post5);

      // Создаем тестовые комментарии
      final comment1 = Comment(
        id: 1,
        postId: 1,
        userId: 2,
        content: 'Отличная инициатива! Готовы к сотрудничеству.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final comment2 = Comment(
        id: 2,
        postId: 1,
        userId: 3,
        content: 'Интересный продукт. Расскажите подробнее о возможностях.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      final comment3 = Comment(
        id: 3,
        postId: 2,
        userId: 1,
        content: 'Поддерживаю! Экология - это важно.',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      );

      final comment4 = Comment(
        id: 4,
        postId: 3,
        userId: 1,
        content: 'Обязательно запишусь на курс!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );

      final comment5 = Comment(
        id: 5,
        postId: 3,
        userId: 2,
        content: 'Отличная возможность для развития!',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      );

      // Сохраняем комментарии
      await _dbHelper.insertComment(comment1);
      await _dbHelper.insertComment(comment2);
      await _dbHelper.insertComment(comment3);
      await _dbHelper.insertComment(comment4);
      await _dbHelper.insertComment(comment5);

      print('✅ Тестовые данные успешно добавлены в локальную базу данных');
    } catch (e) {
      print('❌ Ошибка при добавлении тестовых данных: $e');
      rethrow;
    }
  }

  // ==================== СЕРВЕРНЫЕ ДАННЫЕ ====================

  static Future<void> insertTestDataToServer() async {
    try {
      print('🔄 Отправка тестовых данных на сервер...');

      // Регистрируем тестовых пользователей на сервере
      final user1Id = await _registerUserOnServer(
        email: 'ivan@techstart.ru',
        password: 'test123',
        name: 'Иван Иванов',
        phone: '+7 (999) 123-45-67',
        position: 'CEO',
        companyName: 'TechStart',
      );

      final user2Id = await _registerUserOnServer(
        email: 'anna@greeneco.ru',
        password: 'test123',
        name: 'Анна Смирнова',
        phone: '+7 (999) 987-65-43',
        position: 'CTO',
        companyName: 'GreenEco',
      );

      final user3Id = await _registerUserOnServer(
        email: 'pavel@eduplatform.ru',
        password: 'test123',
        name: 'Павел Козлов',
        phone: '+7 (999) 555-44-33',
        position: 'Founder',
        companyName: 'EduPlatform',
      );

      // Создаем компании на сервере
      final company1Id = await _createCompanyOnServer(
        name: 'TechStart',
        description: 'Инновационная финтех-компания',
        industry: 'Финансы',
        location: 'Москва',
        logoUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=TS',
        employeeCount: 50,
        contactEmail: 'info@techstart.ru',
        userId: user1Id,
      );

      final company2Id = await _createCompanyOnServer(
        name: 'GreenEco',
        description: 'Экологичные решения для бизнеса',
        industry: 'Экология',
        location: 'Санкт-Петербург',
        logoUrl: 'https://via.placeholder.com/100/4CAF50/FFFFFF?text=GE',
        employeeCount: 25,
        contactEmail: 'info@greeneco.ru',
        userId: user2Id,
      );

      final company3Id = await _createCompanyOnServer(
        name: 'EduPlatform',
        description: 'Онлайн-образование для всех',
        industry: 'Образование',
        location: 'Казань',
        logoUrl: 'https://via.placeholder.com/100/2196F3/FFFFFF?text=EP',
        employeeCount: 15,
        contactEmail: 'info@eduplatform.ru',
        userId: user3Id,
      );

      // Создаем посты на сервере
      await _createPostOnServer(
        content: 'Запустили новый финтех-продукт! Ищем партнеров для масштабирования. Наша платформа поможет малому бизнесу оптимизировать финансовые процессы.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Финтех+Продукт',
        companyId: company1Id,
        userId: user1Id,
      );

      await _createPostOnServer(
        content: 'Открыли новый центр переработки в Санкт-Петербурге! Присоединяйтесь к нашей миссии по созданию экологичного будущего.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Центр+Переработки',
        companyId: company2Id,
        userId: user2Id,
      );

      await _createPostOnServer(
        content: 'Новый курс по Flutter уже доступен! Записывайтесь на платформе и станьте разработчиком мобильных приложений.',
        imageUrl: 'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Курс+Flutter',
        companyId: company3Id,
        userId: user3Id,
      );

      await _createPostOnServer(
        content: 'Провели успешную презентацию нашего продукта на конференции FinTech 2024. Получили много положительных отзывов!',
        imageUrl: null,
        companyId: company1Id,
        userId: user1Id,
      );

      await _createPostOnServer(
        content: 'Наша команда приняла участие в экологическом форуме. Обсудили перспективы развития зеленых технологий в России.',
        imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Эко+Форум',
        companyId: company2Id,
        userId: user2Id,
      );

      print('✅ Тестовые данные успешно отправлены на сервер');
    } catch (e) {
      print('❌ Ошибка при отправке данных на сервер: $e');
      rethrow;
    }
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ====================

  static Future<int> _registerUserOnServer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String position,
    required String companyName,
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
        return response.data['user_id'];
      }
    } catch (e) {
      print('Ошибка регистрации пользователя $email: $e');
      // Возвращаем фиктивный ID для продолжения
      return 1;
    }
    return 1;
  }

  static Future<int> _createCompanyOnServer({
    required String name,
    required String description,
    required String industry,
    required String location,
    String? logoUrl,
    required int employeeCount,
    required String contactEmail,
    required int userId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/companies',
        data: {
          'name': name,
          'description': description,
          'industry': industry,
          'location': location,
          'logo_url': logoUrl,
          'employee_count': employeeCount,
          'contact_email': contactEmail,
        },
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return response.data['company_id'];
      }
    } catch (e) {
      print('Ошибка создания компании $name: $e');
      // Возвращаем фиктивный ID для продолжения
      return 1;
    }
    return 1;
  }

  static Future<void> _createPostOnServer({
    required String content,
    String? imageUrl,
    required int companyId,
    required int userId,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/posts',
        data: {
          'content': content,
          'company_id': companyId,
          'image_url': imageUrl,
        },
        queryParameters: {'user_id': userId},
      );
    } catch (e) {
      print('Ошибка создания поста: $e');
    }
  }

  static Future<void> clearTestData() async {
    try {
      await _dbHelper.deleteDatabase();
      print('✅ Тестовые данные успешно удалены');
    } catch (e) {
      print('❌ Ошибка при удалении тестовых данных: $e');
      rethrow;
    }
  }
} 