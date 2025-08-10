#!/usr/bin/env python3
"""
Скрипт для добавления тестовых данных на сервер coFound
Запускается автоматически при старте сервера
"""

import requests
import time
from datetime import datetime, timedelta

# Конфигурация
SERVER_URL = "http://62.113.37.96:8000"
# SERVER_URL = "http://localhost:8000"  # Для локального тестирования

def register_user(email, password, name, phone, position, company_name):
    """Регистрация пользователя на сервере"""
    try:
        response = requests.post(f"{SERVER_URL}/register", json={
            'email': email,
            'password': password,
            'name': name,
            'phone': phone,
            'position': position,
            'company_name': company_name,
        })
        
        if response.status_code == 200:
            return response.json()['user_id']
        else:
            print(f"Ошибка регистрации {email}: {response.text}")
            return None
    except Exception as e:
        print(f"Ошибка при регистрации {email}: {e}")
        return None

def create_company(name, description, industry, location, logo_url, employee_count, contact_email, user_id):
    """Создание компании на сервере"""
    try:
        response = requests.post(f"{SERVER_URL}/companies", json={
            'name': name,
            'description': description,
            'industry': industry,
            'location': location,
            'logo_url': logo_url,
            'employee_count': employee_count,
            'contact_email': contact_email,
        }, params={'user_id': user_id})
        
        if response.status_code == 200:
            return response.json()['company_id']
        else:
            print(f"Ошибка создания компании {name}: {response.text}")
            return None
    except Exception as e:
        print(f"Ошибка при создании компании {name}: {e}")
        return None

def create_post(content, company_id, user_id, image_url=None):
    """Создание поста на сервере"""
    try:
        data = {
            'content': content,
            'company_id': company_id,
        }
        if image_url:
            data['image_url'] = image_url
            
        response = requests.post(f"{SERVER_URL}/posts", json=data, params={'user_id': user_id})
        
        if response.status_code == 200:
            return response.json()['post_id']
        else:
            print(f"Ошибка создания поста: {response.text}")
            return None
    except Exception as e:
        print(f"Ошибка при создании поста: {e}")
        return None

def create_comment(post_id, content, user_id):
    """Создание комментария на сервере"""
    try:
        response = requests.post(f"{SERVER_URL}/posts/{post_id}/comments", json={
            'content': content,
        }, params={'user_id': user_id})
        
        if response.status_code == 200:
            return True
        else:
            print(f"Ошибка создания комментария: {response.text}")
            return False
    except Exception as e:
        print(f"Ошибка при создании комментария: {e}")
        return False

def setup_test_data():
    """Основная функция для настройки тестовых данных"""
    print("🚀 Начинаем настройку тестовых данных...")
    
    # Проверяем доступность сервера
    try:
        response = requests.get(f"{SERVER_URL}/users")
        if response.status_code == 200:
            existing_users = response.json()
            if len(existing_users) > 0:
                print("✅ Тестовые данные уже существуют на сервере")
                return
    except:
        print("❌ Сервер недоступен")
        return
    
    # Регистрируем тестовых пользователей
    print("👥 Регистрируем пользователей...")
    
    user1_id = register_user(
        email='ivan@techstart.ru',
        password='test123',
        name='Иван Иванов',
        phone='+7 (999) 123-45-67',
        position='CEO',
        company_name='TechStart'
    )
    
    user2_id = register_user(
        email='anna@greeneco.ru',
        password='test123',
        name='Анна Смирнова',
        phone='+7 (999) 987-65-43',
        position='CTO',
        company_name='GreenEco'
    )
    
    user3_id = register_user(
        email='pavel@eduplatform.ru',
        password='test123',
        name='Павел Козлов',
        phone='+7 (999) 555-44-33',
        position='Founder',
        company_name='EduPlatform'
    )
    
    if not all([user1_id, user2_id, user3_id]):
        print("❌ Не удалось зарегистрировать всех пользователей")
        return
    
    # Создаем компании
    print("🏢 Создаем компании...")
    
    company1_id = create_company(
        name='TechStart',
        description='Инновационная финтех-компания',
        industry='Финансы',
        location='Москва',
        logo_url='https://via.placeholder.com/100/4CAF50/FFFFFF?text=TS',
        employee_count=50,
        contact_email='info@techstart.ru',
        user_id=user1_id
    )
    
    company2_id = create_company(
        name='GreenEco',
        description='Экологичные решения для бизнеса',
        industry='Экология',
        location='Санкт-Петербург',
        logo_url='https://via.placeholder.com/100/4CAF50/FFFFFF?text=GE',
        employee_count=25,
        contact_email='info@greeneco.ru',
        user_id=user2_id
    )
    
    company3_id = create_company(
        name='EduPlatform',
        description='Онлайн-образование для всех',
        industry='Образование',
        location='Казань',
        logo_url='https://via.placeholder.com/100/2196F3/FFFFFF?text=EP',
        employee_count=15,
        contact_email='info@eduplatform.ru',
        user_id=user3_id
    )
    
    if not all([company1_id, company2_id, company3_id]):
        print("❌ Не удалось создать все компании")
        return
    
    # Создаем посты
    print("📝 Создаем посты...")
    
    posts = [
        {
            'content': 'Запустили новый финтех-продукт! Ищем партнеров для масштабирования. Наша платформа поможет малому бизнесу оптимизировать финансовые процессы.',
            'image_url': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Финтех+Продукт',
            'company_id': company1_id,
            'user_id': user1_id
        },
        {
            'content': 'Открыли новый центр переработки в Санкт-Петербурге! Присоединяйтесь к нашей миссии по созданию экологичного будущего.',
            'image_url': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Центр+Переработки',
            'company_id': company2_id,
            'user_id': user2_id
        },
        {
            'content': 'Новый курс по Flutter уже доступен! Записывайтесь на платформе и станьте разработчиком мобильных приложений.',
            'image_url': 'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Курс+Flutter',
            'company_id': company3_id,
            'user_id': user3_id
        },
        {
            'content': 'Провели успешную презентацию нашего продукта на конференции FinTech 2024. Получили много положительных отзывов!',
            'image_url': None,
            'company_id': company1_id,
            'user_id': user1_id
        },
        {
            'content': 'Наша команда приняла участие в экологическом форуме. Обсудили перспективы развития зеленых технологий в России.',
            'image_url': 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Эко+Форум',
            'company_id': company2_id,
            'user_id': user2_id
        }
    ]
    
    post_ids = []
    for post_data in posts:
        post_id = create_post(**post_data)
        if post_id:
            post_ids.append(post_id)
            time.sleep(0.5)  # Небольшая задержка между запросами
    
    if not post_ids:
        print("❌ Не удалось создать посты")
        return
    
    # Создаем комментарии
    print("💬 Создаем комментарии...")
    
    comments = [
        {'post_id': post_ids[0], 'content': 'Отличная инициатива! Готовы к сотрудничеству.', 'user_id': user2_id},
        {'post_id': post_ids[0], 'content': 'Интересный продукт. Расскажите подробнее о возможностях.', 'user_id': user3_id},
        {'post_id': post_ids[1], 'content': 'Поддерживаю! Экология - это важно.', 'user_id': user1_id},
        {'post_id': post_ids[2], 'content': 'Обязательно запишусь на курс!', 'user_id': user1_id},
        {'post_id': post_ids[2], 'content': 'Отличная возможность для развития!', 'user_id': user2_id},
    ]
    
    for comment_data in comments:
        create_comment(**comment_data)
        time.sleep(0.3)  # Небольшая задержка между запросами
    
    print("✅ Тестовые данные успешно добавлены на сервер!")
    print(f"📊 Создано: 3 пользователя, 3 компании, {len(post_ids)} постов, {len(comments)} комментариев")

if __name__ == "__main__":
    setup_test_data() 