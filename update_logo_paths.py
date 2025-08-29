import re

def update_logo_paths():
    """Обновляет пути к логотипам в файле компаний"""
    
    # Читаем файл
    with open('комапнии.py', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Маппинг доменов к файлам логотипов
    logo_mapping = {
        'sber.ru': 'sber - logo.png',
        'vtb.ru': 'vtb.ru.png',
        'alfabank.ru': 'alfabank.ru.png',
        'tinkoff.ru': 'tinkoff.ru.png',
        'gazprom-neft.ru': 'gazprom-neft.ru.png',
        'rosneft.ru': 'rosneft.ru.png',
        'lukoil.ru': 'lukoil.ru.png',
        'sibur.ru': 'sibur.ru.png',
        'yandex.ru': 'yandex.ru.png',
        'vk.com': 'vk.com.png',
        '1c.ru': '1c.ru.png',
        'kaspersky.ru': 'kaspersky.ru.png',
        'rt.ru': 'rt.ru.png',
        'mts.ru': 'mts.ru.png',
        'megafon.ru': 'megafon.ru.png',
        'beeline.ru': 'beeline.ru.png',
        'ozon.ru': 'ozon.ru.png',
        'wildberries.ru': 'wildberries.ru.png',
        'market.yandex.ru': 'market.yandex.ru.png',
        'avito.ru': 'avito.ru.png',
        'hh.ru': 'hh.ru.png',
        'eda.yandex.ru': 'eda.yandex.ru.png',
        'samokat.tech': 'samolet.ru.png',  # Заменяем на Самолёт
        'cdek.ru': 'cdek.ru.png',
        'pochta.ru': 'pochta.ru.png',
        'selectel.ru': 'selectel.ru.png',
        'kontur.ru': 'kontur.ru.png',
        '2gis.ru': '2gis.ru.png',
        'invitro.ru': 'invitro.ru.png',
        'msu.ru': 'msu.ru.png',
        'mipt.ru': 'mipt.ru.png',
        'itmo.ru': 'itmo.ru.png',
        'hse.ru': 'hse.ru.png',
        'skoltech.ru': 'skoltech.ru.png',
        'misis.ru': 'misis.ru.png',
        'nrcki.ru': 'nrcki.ru.png',
        'ispras.ru': 'ispras.ru.png',
        'timacad.ru': 'timacad.ru.png',
        'vir.nw.ru': 'nrcki.ru.png',  # Заменяем на НИЦ
        'rosatom.ru': 'rosatom.ru.png',
        'rostec.ru': 'rostec.ru.png',
        'rzd.ru': 'rzd.ru.png',
        'aeroflot.ru': 'aeroflot.ru.png',
        's7.ru': 's7.ru.png',
        'gazprombank.ru': 'gazprombank.ru.png',
        'rshb.ru': 'rshb.ru.png',
        'ingos.ru': 'ingos.ru.png',
        'reso.ru': 'reso.ru.png',
        'alfastrah.ru': 'alfastrah.ru.png',
        'x5.ru': 'x5.ru.png',
        'magnit.ru': 'magnit.ru.png',
        'vkusvill.ru': 'vkusvill.ru.png',
        'mvideo.ru': 'mvideo.ru.png',
        'dns-shop.ru': 'dns-shop.ru.png',
        'citilink.ru': 'citilink.ru.png',
        'hoff.ru': 'hoff.ru.png',
        'okmarket.ru': 'okmarket.ru.png',
        'lenta.com': 'lenta.com.png',
        'petrovich.ru': 'petrovich.ru.png',
        'pik.ru': 'pik.ru.png',
        'samolet.ru': 'samolet.ru.png',
        'lsrgroup.ru': 'lsrgroup.ru.png',
        'ptsecurity.com': 'ptsecurity.com.png',
        'naumen.ru': 'naumen.ru.png',
        'croc.ru': 'croc.ru.png',
        't1.ru': 't1.ru.png',
        'yadro.com': 'yadro.com.png',
        'sbermarket.ru': 'sbermarket.ru.png',
        'fix-price.ru': 'fix-price.ru.png',
        'sovcombank.ru': 'sovcombank.ru.png',
        'tochka.com': 'tinkoff.ru.png',  # Заменяем на Тинькофф
        'yoomoney.ru': 'yoomoney.ru.png',
        'yookassa.ru': 'yookassa.ru.png',
        'qiwi.com': 'qiwi.com.png',
        'vsk.ru': 'vsk.ru.png',
        'sogaz.ru': 'sogaz.ru.png',
        'delimobil.ru': 'delimobil.ru.png',
        'belkacar.ru': 'belkacar.ru.png',
        'whoosh.bike': 'whoosh.bike.png',
        'drive.yandex.ru': 'drive.yandex.ru.png',
        'delivery-club.ru': 'delivery-club.ru.png',
        'utkonos.ru': 'utkonos.ru.png',
        'dodopizza.ru': 'dodopizza.ru.png',
        'detmir.ru': 'detmir.ru.png',
        'ostin.com': 'ostin.com.png',
        'gloria-jeans.ru': 'gloria-jeans.ru.png',
        'kari.com': 'kari.com.png',
        'kazanexpress.ru': 'kazanexpress.ru.png',
        'petshop.ru': 'petshop.ru.png',
        'apteka.ru': 'apteka.ru.png',
        'skillbox.ru': 'skillbox.ru.png',
        'netology.ru': 'netology.ru.png',
        'gb.ru': 'gb.ru.png',
        'skyeng.ru': 'skyeng.ru.png',
        'practicum.yandex.ru': 'yandex.ru.png',  # Заменяем на Яндекс
        'ivi.ru': 'ivi.ru.png',
        'okko.tv': 'okko.tv.png',
        'kion.ru': 'kion.ru.png',
    }
    
    # Заменяем все URL на локальные пути
    for domain, logo_file in logo_mapping.items():
        old_pattern = f'"https://logo.clearbit.com/{domain}?size=256"'
        new_path = f'"assets/logo/{logo_file}"'
        content = content.replace(old_pattern, new_path)
    
    # Записываем обновленный файл
    with open('комапнии.py', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Пути к логотипам обновлены!")

if __name__ == "__main__":
    update_logo_paths()
