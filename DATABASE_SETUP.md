# Настройка базы данных для coFound

## Обзор

Мы создали полноценную систему базы данных для приложения coFound, которая включает:

### Серверная часть (Python/FastAPI)
- **Файл**: `register.py`
- **База данных**: SQLite (`cofound.db`)
- **API**: RESTful endpoints для всех операций

### Клиентская часть (Flutter)
- **Модели данных**: `lib/models/`
- **Сервисы**: `lib/services/`
- **Репозитории**: `lib/repositories/`
- **Локальная БД**: SQLite через `DatabaseHelper`

## Структура базы данных

### Таблицы

1. **users** - Пользователи
   - id, email, password_hash, name, phone, position, company_name, avatar_url, created_at

2. **companies** - Компании
   - id, name, description, industry, location, logo_url, employee_count, contact_email, created_by, created_at

3. **posts** - Посты/публикации
   - id, user_id, company_id, content, image_url, likes_count, comments_count, created_at

4. **comments** - Комментарии к постам
   - id, post_id, user_id, content, created_at

5. **likes** - Лайки постов
   - id, post_id, user_id, created_at

6. **business_cards** - Визитки пользователей
   - id, user_id, name, position, company_name, phone, email, social_media_link, qr_code_data, created_at

7. **subscriptions** - Подписки пользователей
   - id, user_id, plan_type, start_date, end_date, status

## Запуск сервера

1. Установите зависимости:
```bash
pip install fastapi uvicorn sqlalchemy passlib
```

2. Запустите сервер:
```bash
python register.py
```

Сервер будет доступен по адресу: `http://62.113.37.96:8000`

## API Endpoints

### Пользователи
- `POST /register` - Регистрация
- `POST /login` - Вход
- `GET /users/{user_id}` - Получить пользователя
- `PUT /users/{user_id}` - Обновить пользователя

### Компании
- `GET /companies` - Получить все компании
- `POST /companies` - Создать компанию

### Посты
- `GET /posts` - Получить все посты
- `POST /posts` - Создать пост
- `POST /posts/{post_id}/comments` - Добавить комментарий
- `POST /posts/{post_id}/like` - Лайкнуть пост

### Визитки
- `GET /business-cards/{user_id}` - Получить визитки пользователя
- `POST /business-cards` - Создать визитку

### Подписки
- `POST /subscriptions` - Создать подписку

## Использование в Flutter

### Инициализация

```dart
import 'services/services.dart';
import 'repositories/repositories.dart';

final userRepository = UserRepository();
final postRepository = PostRepository();
final companyRepository = CompanyRepository();
final businessCardRepository = BusinessCardRepository();
```

### Примеры использования

#### Регистрация пользователя
```dart
final user = await userRepository.registerUser(
  email: 'test@example.com',
  password: 'password123',
  name: 'Иван Иванов',
  phone: '+7 (999) 123-45-67',
  position: 'CEO',
  companyName: 'TechStart',
);
```

#### Создание поста
```dart
final post = await postRepository.createPost(
  userId: 1,
  content: 'Новый пост!',
  companyId: 1,
  imageUrl: 'https://example.com/image.jpg',
);
```

#### Создание компании
```dart
final company = await companyRepository.createCompany(
  userId: 1,
  name: 'TechStart',
  description: 'Инновационная IT компания',
  industry: 'IT',
  location: 'Москва',
  employeeCount: 10,
  contactEmail: 'info@techstart.ru',
);
```

#### Создание визитки
```dart
final card = await businessCardRepository.createBusinessCard(
  userId: 1,
  name: 'Иван Иванов',
  position: 'CEO',
  companyName: 'TechStart',
  phone: '+7 (999) 123-45-67',
  email: 'ivan@techstart.ru',
  socialMediaLink: 'linkedin.com/in/ivanov',
);
```

## Тестирование

Для тестирования базы данных запустите:

```dart
// В main.dart временно замените home на DatabaseTest
home: const DatabaseTest(),
```

Это покажет результаты тестирования всех операций с базой данных.

## Следующие шаги

1. **Интеграция с UI**: Подключите репозитории к существующим экранам
2. **Аутентификация**: Добавьте систему токенов
3. **Кэширование**: Реализуйте умное кэширование данных
4. **Синхронизация**: Добавьте офлайн-режим с синхронизацией
5. **Миграции**: Настройте систему миграций базы данных

## Структура файлов

```
lib/
├── models/
│   ├── user.dart
│   ├── company.dart
│   ├── post.dart
│   ├── comment.dart
│   ├── subscription.dart
│   └── models.dart
├── services/
│   ├── database_helper.dart
│   ├── user_service.dart
│   ├── post_service.dart
│   ├── company_service.dart
│   ├── business_card_service.dart
│   ├── business_card.dart
│   └── services.dart
├── repositories/
│   ├── user_repository.dart
│   ├── post_repository.dart
│   ├── company_repository.dart
│   ├── business_card_repository.dart
│   └── repositories.dart
└── test_database.dart
```

## Примечания

- Все операции с базой данных асинхронные
- Локальная БД используется как кэш
- Сетевая БД является источником истины
- Обработка ошибок реализована на всех уровнях
- Поддержка офлайн-режима через локальную БД 