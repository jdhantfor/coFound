import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'models/models.dart';

class DatabaseTest extends StatefulWidget {
  const DatabaseTest({super.key});

  @override
  State<DatabaseTest> createState() => _DatabaseTestState();
}

class _DatabaseTestState extends State<DatabaseTest> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _runDatabaseTest();
  }

  Future<void> _runDatabaseTest() async {
    try {
      setState(() {
        _testResult = 'Запуск тестов базы данных...\n';
      });

      // Тест создания пользователя
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Тестовый пользователь',
        phone: '+7 (999) 123-45-67',
        position: 'CEO',
        companyName: 'Test Company',
        createdAt: DateTime.now(),
      );

      final userId = await _dbHelper.insertUser(user);
      _addToResult('Пользователь создан с ID: $userId\n');

      // Тест создания компании
      final company = Company(
        id: 1,
        name: 'Test Company',
        description: 'Тестовая компания',
        industry: 'IT',
        location: 'Москва',
        logoUrl: 'https://example.com/logo.png',
        employeeCount: 10,
        contactEmail: 'info@testcompany.com',
        createdBy: 1,
        createdAt: DateTime.now(),
      );

      final companyId = await _dbHelper.insertCompany(company);
      _addToResult('Компания создана с ID: $companyId\n');

      // Тест создания поста
      final post = Post(
        id: 1,
        userId: 1,
        companyId: 1,
        content: 'Тестовый пост',
        imageUrl: 'https://example.com/image.jpg',
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      final postId = await _dbHelper.insertPost(post);
      _addToResult('Пост создан с ID: $postId\n');

      // Тест создания комментария
      final comment = Comment(
        id: 1,
        postId: 1,
        userId: 1,
        content: 'Тестовый комментарий',
        createdAt: DateTime.now(),
      );

      final commentId = await _dbHelper.insertComment(comment);
      _addToResult('Комментарий создан с ID: $commentId\n');

      // Тест создания визитки
      final businessCard = BusinessCard(
        id: 1,
        userId: 1,
        name: 'Тестовый пользователь',
        position: 'CEO',
        companyName: 'Test Company',
        phone: '+7 (999) 123-45-67',
        email: 'test@example.com',
        socialMediaLink: 'linkedin.com/in/test',
        qrCodeData: 'https://cofound.app/users/1',
        createdAt: DateTime.now(),
      );

      final cardId = await _dbHelper.insertBusinessCard(businessCard);
      _addToResult('Визитка создана с ID: $cardId\n');

      // Тест получения данных
      final retrievedUser = await _dbHelper.getUser(1);
      if (retrievedUser != null) {
        _addToResult('Пользователь получен: ${retrievedUser.name}\n');
      }

      final retrievedCompany = await _dbHelper.getCompany(1);
      if (retrievedCompany != null) {
        _addToResult('Компания получена: ${retrievedCompany.name}\n');
      }

      final posts = await _dbHelper.getAllPosts();
      _addToResult('Получено постов: ${posts.length}\n');

      final comments = await _dbHelper.getCommentsForPost(1);
      _addToResult('Получено комментариев: ${comments.length}\n');

      final cards = await _dbHelper.getBusinessCardsForUser(1);
      _addToResult('Получено визиток: ${cards.length}\n');

      _addToResult('Все тесты пройдены успешно! ✅\n');

    } catch (e) {
      _addToResult('Ошибка: $e\n');
    }
  }

  void _addToResult(String text) {
    setState(() {
      _testResult += text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест базы данных'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Результаты тестирования:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.deleteDatabase();
                setState(() {
                  _testResult = 'База данных очищена\n';
                });
              },
              child: const Text('Очистить базу данных'),
            ),
          ],
        ),
      ),
    );
  }
} 