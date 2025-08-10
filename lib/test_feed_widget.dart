import 'package:flutter/material.dart';
import '/test_feed_data.dart';
import '/app_styles.dart';

class TestFeedWidget extends StatefulWidget {
  const TestFeedWidget({super.key});

  @override
  _TestFeedWidgetState createState() => _TestFeedWidgetState();
}

class _TestFeedWidgetState extends State<TestFeedWidget> {
  bool _isLoading = false;
  String _status = '';

  Future<void> _insertTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Добавление тестовых данных в локальную базу...';
    });

    try {
      await TestFeedData.insertTestData();
      setState(() {
        _status = '✅ Тестовые данные успешно добавлены в локальную базу!\n\nТеперь можете перейти в ленту новостей для просмотра постов.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Ошибка при добавлении данных: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _insertTestDataToServer() async {
    setState(() {
      _isLoading = true;
      _status = 'Отправка тестовых данных на сервер...\nЭто может занять несколько секунд.';
    });

    try {
      await TestFeedData.insertTestDataToServer();
      setState(() {
        _status = '✅ Тестовые данные успешно отправлены на сервер!\n\nТеперь в основном приложении появятся тестовые записи. Перейдите в ленту новостей для просмотра.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Ошибка при отправке данных на сервер: $e\n\nПроверьте подключение к интернету и доступность сервера.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearTestData() async {
    setState(() {
      _isLoading = true;
      _status = 'Удаление тестовых данных...';
    });

    try {
      await TestFeedData.clearTestData();
      setState(() {
        _status = '✅ Тестовые данные успешно удалены!';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Ошибка при удалении данных: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppStyles.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'coFound',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Тестирование ленты новостей',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Этот экран позволяет добавить тестовые данные для демонстрации функционала ленты новостей.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            // Кнопки управления
            Column(
              children: [
                // Кнопка отправки на сервер
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _insertTestDataToServer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Отправка на сервер...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload, size: 20),
                              SizedBox(width: 8),
                              Text('Отправить данные на сервер'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Кнопки локальных операций
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _insertTestData,
                        style: AppStyles.elevatedButtonStyle,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storage, size: 20),
                            SizedBox(width: 8),
                            Text('Добавить локально'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _clearTestData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 8),
                            Text('Очистить'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Статус
            if (_status.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Информация о тестовых данных
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppStyles.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Что будет добавлено:',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem('👥 3 пользователя', 'Иван Иванов, Анна Смирнова, Павел Козлов'),
                  _buildInfoItem('🏢 3 компании', 'TechStart, GreenEco, EduPlatform'),
                  _buildInfoItem('📝 5 постов', 'С разными изображениями и контентом'),
                  _buildInfoItem('💬 5 комментариев', 'К различным постам'),
                  const SizedBox(height: 16),
                  
                  // Различия между локальным и серверным режимом
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📡 Отправка на сервер:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Данные появятся в основном приложении\n• Доступны всем пользователям\n• Требует подключения к интернету',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💾 Локальное добавление:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Данные только в тестовом режиме\n• Не влияет на основное приложение\n• Работает без интернета',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppStyles.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppStyles.secondaryGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 