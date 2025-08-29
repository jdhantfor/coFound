import sqlite3
import os
import sys

# Добавляем путь к папке с логотипами
logo_dir = "assets/logo"

def get_logo_path(company_name, domain):
    """Получает путь к логотипу компании"""
    # Создаем маппинг названий компаний к файлам логотипов
    logo_mapping = {
        "Сбер": "sber - logo.png",
        "ВТБ": "vtb.ru.png",
        "Альфа-Банк": "alfabank.ru.png",
        "Тинькофф": "tinkoff.ru.png",
        "Газпром нефть": "gazprom-neft.ru.png",
        "Роснефть": "rosneft.ru.png",
        "Лукойл": "lukoil.ru.png",
        "Сибур": "sibur.ru.png",
        "Яндекс": "yandex.ru.png",
        "VK": "vk.com.png",
        "1С": "1c.ru.png",
        "Kaspersky": "kaspersky.ru.png",
        "Ростелеком": "rt.ru.png",
        "МТС": "mts.ru.png",
        "МегаФон": "megafon.ru.png",
        "Билайн": "beeline.ru.png",
        "Ozon": "ozon.ru.png",
        "Wildberries": "wildberries.ru.png",
        "Яндекс Маркет": "market.yandex.ru.png",
        "Авито": "avito.ru.png",
        "HeadHunter": "hh.ru.png",
        "Яндекс Еда": "eda.yandex.ru.png",
        "СДЭК": "cdek.ru.png",
        "Почта России": "pochta.ru.png",
        "Selectel": "selectel.ru.png",
        "СКБ Контур": "kontur.ru.png",
        "2ГИС": "2gis.ru.png",
        "Инвитро": "invitro.ru.png",
        "МГУ им. М.В. Ломоносова": "msu.ru.png",
        "МФТИ": "mipt.ru.png",
        "Университет ИТМО": "itmo.ru.png",
        "НИУ ВШЭ": "hse.ru.png",
        "Сколтех": "skoltech.ru.png",
        "НИТУ МИСИС": "misis.ru.png",
        "НИЦ «Курчатовский институт»": "nrcki.ru.png",
        "ИСП РАН": "ispras.ru.png",
        "РГАУ-МСХА им. Тимирязева": "timacad.ru.png",
        "Росатом": "rosatom.ru.png",
        "Ростех": "rostec.ru.png",
        "РЖД": "rzd.ru.png",
        "Аэрофлот": "aeroflot.ru.png",
        "S7 Airlines": "s7.ru.png",
        "Газпромбанк": "gazprombank.ru.png",
        "Россельхозбанк": "rshb.ru.png",
        "Ингосстрах": "ingos.ru.png",
        "РЕСО-Гарантия": "reso.ru.png",
        "АльфаСтрахование": "alfastrah.ru.png",
        "X5 Group": "x5.ru.png",
        "Магнит": "magnit.ru.png",
        "ВкусВилл": "vkusvill.ru.png",
        "М.Видео-Эльдорадо": "mvideo.ru.png",
        "DNS": "dns-shop.ru.png",
        "Ситилинк": "citilink.ru.png",
        "Hoff": "hoff.ru.png",
        "O'Кей": "okmarket.ru.png",
        "Лента": "lenta.com.png",
        "Петрович": "petrovich.ru.png",
        "ПИК": "pik.ru.png",
        "Самолёт": "samolet.ru.png",
        "ЛСР Групп": "lsrgroup.ru.png",
        "Positive Technologies": "ptsecurity.com.png",
        "NAUMEN": "naumen.ru.png",
        "КРОК": "croc.ru.png",
        "T1": "t1.ru.png",
        "YADRO": "yadro.com.png",
        "СберМаркет": "sbermarket.ru.png",
        "Fix Price": "fix-price.ru.png",
        "Совкомбанк": "sovcombank.ru.png",
        "YooMoney": "yoomoney.ru.png",
        "ЮKassa": "yookassa.ru.png",
        "QIWI": "qiwi.com.png",
        "ВСК": "vsk.ru.png",
        "СОГАЗ": "sogaz.ru.png",
        "Делимобиль": "delimobil.ru.png",
        "BelkaCar": "belkacar.ru.png",
        "Whoosh": "whoosh.bike.png",
        "Яндекс Драйв": "drive.yandex.ru.png",
        "Delivery Club": "delivery-club.ru.png",
        "Утконос": "utkonos.ru.png",
        "Dodo Pizza": "dodopizza.ru.png",
        "Детский мир": "detmir.ru.png",
        "O'STIN": "ostin.com.png",
        "Gloria Jeans": "gloria-jeans.ru.png",
        "Kari": "kari.com.png",
        "KazanExpress": "kazanexpress.ru.png",
        "Petshop.ru": "petshop.ru.png",
        "Apteka.ru": "apteka.ru.png",
        "Skillbox": "skillbox.ru.png",
        "Нетология": "netology.ru.png",
        "GeekBrains": "gb.ru.png",
        "Skyeng": "skyeng.ru.png",
        "ivi": "ivi.ru.png",
        "Okko": "okko.tv.png",
        "KION": "kion.ru.png",
    }
    
    # Ищем логотип по названию компании
    logo_file = logo_mapping.get(company_name)
    if logo_file and os.path.exists(os.path.join(logo_dir, logo_file)):
        return f"assets/logo/{logo_file}"
    
    return None

def seed_russian_companies():
    """Загружает русские компании в базу данных"""
    
    # Импортируем данные компаний
    from комапнии import companies
    
    # Подключаемся к базе данных
    conn = sqlite3.connect('cofound.db')
    cursor = conn.cursor()
    
    try:
        # Создаем таблицу companies если она не существует
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS companies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                industry TEXT,
                location TEXT,
                logo_url TEXT,
                email TEXT,
                employee_count INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Удаляем все существующие компании
        cursor.execute("DELETE FROM companies")
        print("Старые компании удалены из базы данных")
        
        # Добавляем новые русские компании
        for company in companies:
            # Получаем путь к логотипу
            logo_path = get_logo_path(company['name'], company.get('logo', ''))
            
            # Добавляем компанию в базу данных
            cursor.execute("""
                INSERT INTO companies (name, description, industry, location, logo_url, email)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                company['name'],
                company['desc'],
                company['industry'],
                company['location'],
                logo_path or company.get('logo', ''),
                company.get('email', '')
            ))
            
            print(f"Добавлена компания: {company['name']}")
        
        # Сохраняем изменения
        conn.commit()
        print(f"Успешно добавлено {len(companies)} русских компаний")
        
    except Exception as e:
        print(f"Ошибка при загрузке компаний: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    seed_russian_companies()
