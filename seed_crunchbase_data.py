#!/usr/bin/env python3
"""
Seed server with companies and events inspired by Crunchbase trends.
Server is treated as source of truth; script creates companies (if missing)
and posts (events) in Russian.

Usage (Windows):
  py seed_crunchbase_data.py

Requires: requests
"""

import requests
import random
import json
from typing import Dict, List, Tuple, Optional

SERVER = "http://62.113.37.96:8000"
# По умолчанию используем первого пользователя, но далее создадим 20 авторов
SEED_USER_ID = 1

FAKE_AUTHORS: List[Dict[str, str]] = [
    {"name": "Алексей Смирнов", "email": "alexey.smirnov+seed1@example.com", "avatar": "assets/avatar_alexey.svg"},
    {"name": "Мария Иванова", "email": "maria.ivanova+seed2@example.com", "avatar": "assets/avatar_maria.svg"},
    {"name": "Иван Петров", "email": "ivan.petrov+seed3@example.com", "avatar": "assets/avatar_ivan.svg"},
    {"name": "Ольга Кузнецова", "email": "olga.kuz+seed4@example.com", "avatar": "assets/avatar_olga.svg"},
    {"name": "Дмитрий Соколов", "email": "dmitry.sokolov+seed5@example.com", "avatar": "assets/avatar_dmitry.svg"},
    {"name": "Анна Попова", "email": "anna.popova+seed6@example.com", "avatar": "assets/avatar_anna.svg"},
    {"name": "Сергей Васильев", "email": "sergey.vasiliev+seed7@example.com", "avatar": "assets/avatar_sergey.svg"},
    {"name": "Елена Морозова", "email": "elena.morozova+seed8@example.com", "avatar": "assets/avatar_elena.svg"},
    {"name": "Павел Волков", "email": "pavel.volkov+seed9@example.com", "avatar": "assets/avatar_pavel.svg"},
    {"name": "Наталья Новикова", "email": "natalia.novikova+seed10@example.com", "avatar": "assets/avatar_natalia.svg"},
    {"name": "Кирилл Фёдоров", "email": "kirill.fedorov+seed11@example.com", "avatar": "assets/avatar_kirill.svg"},
    {"name": "Виктория Белова", "email": "victoria.belova+seed12@example.com", "avatar": "assets/avatar_victoria.svg"},
    {"name": "Роман Ковалев", "email": "roman.kovalev+seed13@example.com", "avatar": "assets/avatar_roman.svg"},
    {"name": "Юлия Медведева", "email": "yulia.medvedeva+seed14@example.com", "avatar": "assets/avatar_yulia.svg"},
    {"name": "Никита Захаров", "email": "nikita.zakharov+seed15@example.com", "avatar": "assets/avatar_nikita.svg"},
    {"name": "Татьяна Комарова", "email": "tatyana.komarova+seed16@example.com", "avatar": "assets/avatar_tatyana.svg"},
    {"name": "Михаил Орлов", "email": "mikhail.orlov+seed17@example.com", "avatar": "assets/avatar_mikhail.svg"},
    {"name": "Светлана Киселёва", "email": "svetlana.kiseleva+seed18@example.com", "avatar": "assets/avatar_svetlana.svg"},
    {"name": "Егор Никитин", "email": "egor.nikitin+seed19@example.com", "avatar": "assets/avatar_egor.svg"},
    {"name": "Алина Павлова", "email": "alina.pavlova+seed20@example.com", "avatar": "assets/avatar_alina.svg"},
]

def _get_companies() -> List[Dict]:
    r = requests.get(f"{SERVER}/companies", timeout=20)
    r.raise_for_status()
    return r.json()

def _ensure_company(name: str, description: str, industry: str, location: str, logo_url: str | None,
                    employee_count: int, contact_email: str) -> int:
    existing = _get_companies()
    for c in existing:
        if c.get("name", "").strip().lower() == name.strip().lower():
            return c["id"]
    # create
    r = requests.post(
        f"{SERVER}/companies",
        params={"user_id": SEED_USER_ID},
        json={
            "name": name,
            "description": description,
            "industry": industry,
            "location": location,
            "logo_url": logo_url,
            "employee_count": employee_count,
            "contact_email": contact_email,
        },
        timeout=30,
    )
    r.raise_for_status()
    return r.json()["company_id"]

def _create_post(company_id: int, content_ru: str, image_url: str | None = None, author_user_id: int | None = None):
    payload = {
        "content": content_ru,
        "company_id": company_id,
        # backend ожидает строку, передаём пустую если нет изображения
        "image_url": image_url if image_url is not None else "",
    }
    r = requests.post(
        f"{SERVER}/posts",
        params={"user_id": author_user_id if author_user_id else SEED_USER_ID},
        json=payload,
        timeout=30,
    )
    if r.status_code != 200:
        print("Не удалось создать пост:", r.text)

def _get_users() -> List[Dict]:
    r = requests.get(f"{SERVER}/users", timeout=20)
    if r.status_code != 200:
        return []
    return r.json()

def _get_posts() -> List[Dict]:
    r = requests.get(f"{SERVER}/posts", timeout=20)
    if r.status_code != 200:
        return []
    return r.json()

def _choose_author(user_ids: List[int]) -> int:
    if not user_ids:
        return SEED_USER_ID
    return random.choice(user_ids)

def _admin_reset():
    # Очистка данных (по умолчанию не трогаем пользователей)
    r = requests.post(
        f"{SERVER}/admin/reset",
        json={
            "drop_users": False,
            "drop_cards": True,
            "drop_companies": True,
            "drop_posts": True,
            "drop_favorites": True,
            "drop_subscriptions": True,
        },
        timeout=30,
    )
    if r.status_code != 200:
        print("Не удалось очистить данные:", r.text)

def _ensure_user(name: str, email: str, password: str = "seedpass123") -> Optional[int]:
    # Пытаемся залогиниться, если не вышло — регистрируем
    try:
        r = requests.post(f"{SERVER}/login", json={"email": email, "password": password}, timeout=15)
        if r.status_code == 200:
            return r.json().get("user_id")
    except Exception:
        pass

    r = requests.post(
        f"{SERVER}/register",
        json={"email": email, "password": password, "name": name},
        timeout=20,
    )
    if r.status_code == 200:
        return r.json().get("user_id")
    else:
        print("Не удалось создать пользователя:", email, r.text)
        return None

def main():
    # 1) Очистим данные
    _admin_reset()

    # 2) Создадим 20 выдуманных авторов (или используем существующих)
    created_user_ids: List[int] = []
    for author in FAKE_AUTHORS:
        user_id = _ensure_user(author["name"], author["email"])
        if user_id:
            created_user_ids.append(user_id)

    companies = [
        {
            "name": "OpenAI",
            "desc": "OpenAI — ведущая международная исследовательская и технологическая компания в области искусственного интеллекта, основанная в 2015 году. Занимается разработкой и внедрением передовых AI-моделей, включая серию GPT, генератор изображений DALL·E, систему синтеза речи Whisper и видеогенератор Sora. Главная миссия компании — сделать искусственный общий интеллект безопасным, доступным и полезным для всего человечества. OpenAI активно сотрудничает с разработчиками, бизнесом и образовательными учреждениями, предоставляя API и инструменты для интеграции ИИ в продукты и сервисы, а также ведёт масштабные исследования в области этики и безопасности технологий.",
            "industry": "ИИ / ПО",
            "location": "Сан-Франциско",
            "logo": "assets/logo_openai.svg",
            "email": "press@openai.com",
        },
        {
            "name": "Anthropic",
            "desc": "Anthropic — американская исследовательская компания в сфере искусственного интеллекта, созданная в 2021 году бывшими сотрудниками OpenAI. Основная цель — создание безопасных, надёжных и интерпретируемых AI-систем. Флагманский продукт — семейство языковых моделей Claude, применяемых для автоматизации коммуникаций, генерации контента и аналитики. Anthropic известна своим «конституционным» подходом к обучению ИИ, при котором ценности и принципы работы системы задаются явно. Компания активно работает с корпоративным сектором, включая образование, медиа и финансы, делая акцент на этичность и снижение рисков при использовании AI.",
            "industry": "ИИ / Исследования",
            "location": "Сан-Франциско",
            "logo": "assets/logo_anthropic.svg",
            "email": "info@anthropic.com",
        },
        {
            "name": "xAI",
            "desc": "xAI — компания, основанная Илоном Маском в 2023 году, специализирующаяся на разработке AI-инструментов нового поколения. Миссия xAI — «понимание Вселенной» через создание моделей, способных глубже анализировать и объяснять окружающий мир. В команду вошли ведущие специалисты из OpenAI, DeepMind, Google Research и Tesla. Один из ключевых продуктов — чат-бот Grok, интегрированный с социальной платформой X, предоставляющий пользователям контекстуальные ответы и расширенные функции поиска. Компания делает упор на масштабируемость и научную значимость своих решений.",
            "industry": "ИИ / Инфраструктура",
            "location": "Остин",
            "logo": "assets/logo_xai.svg",
            "email": "info@x.ai",
        },
        {
            "name": "Perplexity",
            "desc": "Perplexity — технологическая компания, основанная в 2022 году в Сан-Франциско, разработчик AI-поисковика с цитируемыми источниками и понятными ответами. Сервис позиционируется как «инструмент прямого доступа к знаниям», объединяя функции поиска, чат-бота и аналитики. Perplexity активно развивается, обрабатывая миллионы запросов в день, и нацелена на создание максимально точного и прозрачного поиска. Продукт используется как частными пользователями, так и в корпоративной среде.",
            "industry": "ИИ / Поиск",
            "location": "Сан-Франциско",
            "logo": "assets/logo_perplexity.svg",
            "email": "hello@perplexity.ai",
        },
        {
            "name": "Replit",
            "desc": "Replit — американская компания, запустившая в 2016 году облачную среду разработки с поддержкой множества языков программирования. Платформа позволяет писать, запускать и совместно редактировать код прямо в браузере, а также использовать ИИ-ассистентов для автоматизации рутинных задач. Replit ориентирована на разработчиков любого уровня — от новичков до профессионалов, предоставляя доступ к инструментам программирования из любой точки мира.",
            "industry": "DevTools / ИИ",
            "location": "Сан-Франциско",
            "logo": "assets/logo_replit.svg",
            "email": "contact@replit.com",
        },
        {
            "name": "CoreWeave",
            "desc": "CoreWeave — облачный провайдер GPU-инфраструктуры, основанный в 2017 году. Изначально занималась майнингом криптовалют, но позже полностью перешла на предоставление высокопроизводительных вычислительных ресурсов для AI-разработок, рендеринга и научных расчётов. CoreWeave владеет собственной сетью дата-центров и предлагает масштабируемые решения для клиентов, работающих с генеративным искусственным интеллектом и другими ресурсозатратными задачами.",
            "industry": "Облако / ИИ",
            "location": "Нью‑Йорк",
            "logo": "assets/logo_coreweave.svg",
            "email": "info@coreweave.com",
        },
        {
            "name": "Cohere",
            "desc": "Cohere — канадская компания, основанная в 2019 году, разрабатывающая корпоративные языковые модели и инструменты для интеграции искусственного интеллекта в бизнес-приложения. Решения Cohere ориентированы на крупные организации и позволяют настраивать модели под специфику отрасли, обеспечивая безопасность данных и соответствие требованиям бизнеса.",
            "industry": "ИИ / Энтерпрайз",
            "location": "Торонто",
            "logo": "assets/logo_cohere.svg",
            "email": "press@cohere.com",
        },
        {
            "name": "Glean",
            "desc": "Glean — технологическая компания, созданная в 2019 году, специализирующаяся на AI-поиске по внутренним корпоративным данным. Сервис интегрируется с внутренними системами компании, позволяя сотрудникам быстро находить нужную информацию, документы и ответы на вопросы. Glean помогает оптимизировать рабочие процессы и повышает эффективность взаимодействия внутри организации.",
            "industry": "ИИ / Поиск по компании",
            "location": "Пало‑Альто",
            "logo": "assets/logo_glean.svg",
            "email": "hello@glean.com",
        },
        {
            "name": "ElevenLabs",
            "desc": "ElevenLabs — компания, занимающая лидирующие позиции в области синтеза речи и клонирования голоса. Предлагает инструменты для генерации аудиоконтента с естественным звучанием, многозадачную локализацию и адаптацию голоса под разные языки и стили. Продукция ElevenLabs используется в медиа, игровой индустрии, образовании и корпоративном секторе.",
            "industry": "ИИ / Аудио",
            "location": "Лондон",
            "logo": "assets/logo_elevenlabs.svg",
            "email": "press@elevenlabs.io",
        },
        {
            "name": "Writer",
            "desc": "Writer — разработчик корпоративной платформы генеративного искусственного интеллекта, ориентированной на создание контента в соответствии с брендовыми стандартами. Компания обеспечивает безопасность и контроль данных, предлагая бизнесу решения для автоматизации текстовой работы, улучшения коммуникаций и повышения производительности.",
            "industry": "ИИ / Контент",
            "location": "Сан‑Франциско",
            "logo": "assets/logo_writer.svg",
            "email": "press@writer.com",
        },
        {"name": "Mistral AI", "desc": "Mistral AI — французская компания, основанная в 2023 году в Париже, специализирующаяся на разработке больших языковых моделей (LLM) и инструментов с открытым исходным кодом. Mistral AI делает ставку на прозрачность, доступность и возможность кастомизации моделей под нужды разработчиков и компаний. Их подход сочетает высокую производительность, мультиязычную поддержку и совместимость с существующими AI-фреймворками.", "industry": "ИИ / Модели", "location": "Париж", "logo": "assets/logo_mistral.svg", "email": "hello@mistral.ai"},
        {"name": "Stability AI", "desc": "Stability AI — международная компания с офисом в Лондоне, наиболее известная по созданию Stable Diffusion — одной из самых популярных моделей генерации изображений. Stability AI развивает технологии генеративного ИИ для работы с изображениями, видео и аудио, поддерживая сообщество разработчиков и предоставляя инструменты для креативных индустрий.", "industry": "ИИ / Мультимедиа", "location": "Лондон", "logo": "assets/logo_stability.svg", "email": "press@stability.ai"},
        {"name": "Hugging Face", "desc": "Hugging Face — американская платформа, основанная в 2016 году в Нью-Йорке, ставшая центром экосистемы открытого искусственного интеллекта. Hugging Face предоставляет миллионы моделей, датасетов и Spaces, которые помогают разработчикам, исследователям и компаниям строить и обучать AI-системы. Сильный акцент делается на открытость, коллаборацию и поддержку научного сообщества.", "industry": "ИИ / Платформа", "location": "Нью‑Йорк", "logo": "assets/logo_huggingface.svg", "email": "press@huggingface.co"},
        {"name": "Databricks", "desc": "Databricks — американская компания из Сан-Франциско, разработчик платформы Data + AI, построенной на архитектуре Lakehouse. Databricks объединяет хранение данных, машинное обучение и аналитику в единой экосистеме, позволяя бизнесу эффективно управлять большими данными и извлекать из них ценность.", "industry": "Data / ИИ", "location": "Сан‑Франциско", "logo": "assets/logo_databricks.svg", "email": "press@databricks.com"},
        {"name": "Snowflake", "desc": "Snowflake — облачная платформа для хранения и анализа данных, основанная в 2012 году. Базируется в Боузмене, но имеет глобальное присутствие. Snowflake предоставляет масштабируемое, безопасное и производительное хранилище данных, интегрированное с современными AI-инструментами и аналитическими сервисами.", "industry": "Data / Облако", "location": "Боузмен", "logo": "assets/logo_snowflake.svg", "email": "press@snowflake.com"},
        {"name": "NVIDIA", "desc": "NVIDIA — мировой лидер в разработке графических процессоров (GPU), основанный в 1993 году в Санта-Кларе. Компания стала ключевым игроком в области искусственного интеллекта, предоставляя как аппаратные, так и программные решения для AI-разработки, облачных вычислений и высокопроизводительных симуляций.", "industry": "Полупроводники / ИИ", "location": "Санта‑Клара", "logo": "assets/logo_nvidia.svg", "email": "pressrelations@nvidia.com"},
        {"name": "Adept AI", "desc": "Adept AI — стартап из Сан-Франциско, создающий универсальных AI-агентов, способных выполнять действия в приложениях по описанию на естественном языке. Цель компании — сделать взаимодействие человека с цифровыми системами максимально интуитивным и автоматизированным.", "industry": "ИИ / Агенты", "location": "Сан‑Франциско", "logo": "assets/logo_adept.svg", "email": "info@adept.ai"},
        {"name": "Character AI", "desc": "Character AI — платформа, запущенная в 2021 году, специализирующаяся на создании персональных AI-персонажей и спутников. Пользователи могут взаимодействовать с виртуальными собеседниками, настроенными под уникальные личности, интересы и стили общения.", "industry": "ИИ / Консьюмер", "location": "Пало‑Альто", "logo": "assets/logo_character.svg", "email": "press@character.ai"},
        {"name": "Inflection AI", "desc": "Inflection AI — компания из Пало-Альто, разрабатывающая персональных AI-ассистентов нового поколения. Их продукт Pi ориентирован на дружелюбное, контекстуальное и конфиденциальное взаимодействие с пользователями, а также на поддержку в повседневных задачах.", "industry": "ИИ / Ассистенты", "location": "Пало‑Альто", "logo": "assets/logo_inflection.svg", "email": "hello@inflection.ai"},
        {"name": "Groq", "desc": "Groq — американская технологическая компания из Маунтин-Вью, создатель уникальной архитектуры LPU (Language Processing Unit), которая обеспечивает сверхнизкую задержку при выполнении AI-инференса. Groq ориентируется на рынок, требующий максимальной скорости обработки данных.", "industry": "Аппаратное / ИИ", "location": "Маунтин‑Вью", "logo": "assets/logo_groq.svg", "email": "press@groq.com"},
        {"name": "Together AI", "desc": "Together AI — стартап из Сан-Франциско, предоставляющий открытую инфраструктуру и хостинг AI-моделей. Компания делает упор на доступность и прозрачность вычислительных ресурсов, позволяя разработчикам запускать и обучать модели в облаке.", "industry": "Облако / ИИ", "location": "Сан‑Франциско", "logo": "assets/logo_together.svg", "email": "press@together.ai"},
        {"name": "LangChain", "desc": "LangChain — фреймворк с открытым исходным кодом, упрощающий создание приложений на основе LLM. Позволяет объединять модели, источники данных и API в сложные цепочки логики, ускоряя разработку AI-решений.", "industry": "DevTools / ИИ", "location": "Сан‑Франциско", "logo": "assets/logo_langchain.svg", "email": "hello@langchain.com"},
        {"name": "LlamaIndex", "desc": "LlamaIndex — инструмент и фреймворк для построения систем Retrieval-Augmented Generation (RAG), обеспечивающих доступ к знаниям из различных источников. Помогает разработчикам интегрировать LLM с корпоративными данными.", "industry": "ИИ / RAG", "location": "Чикаго", "logo": "assets/logo_llamaindex.svg", "email": "press@llamaindex.ai"},
        {"name": "Modal", "desc": "Modal — нью-йоркская серверлесс-платформа, позволяющая запускать и масштабировать ML и AI-нагрузки без управления инфраструктурой. Ориентирована на разработчиков, которым важны скорость развёртывания и гибкость.", "industry": "Облако / Серверлесс", "location": "Нью‑Йорк", "logo": "assets/logo_modal.svg", "email": "hello@modal.com"},
        {"name": "Runpod", "desc": "Runpod — американский сервис аренды GPU и облачных серверов для обучения и инференса AI-моделей. Обеспечивает быстрый доступ к мощным вычислительным ресурсам для разработчиков и исследователей.", "industry": "Облако / GPU", "location": "США", "logo": "assets/logo_runpod.svg", "email": "support@runpod.io"},
        {"name": "n8n", "desc": "n8n — берлинская компания, разработчик автоматизационной платформы с открытым исходным кодом. Позволяет строить интеграционные цепочки, включая работу с AI-узлами, без необходимости писать код.", "industry": "Automation / ИИ", "location": "Берлин", "logo": "assets/logo_n8n.svg", "email": "hello@n8n.io"},
        {"name": "Hazy", "desc": "Hazy — британская компания, специализирующаяся на генерации синтетических данных для разработки и тестирования AI-систем. Такие данные позволяют безопасно работать с алгоритмами, избегая утечек персональной информации.", "industry": "Data / Privacy", "location": "Лондон", "logo": "assets/logo_hazy.svg", "email": "info@hazy.com"},
        {"name": "Pinecone", "desc": "Pinecone — разработчик векторной базы данных для AI-поиска и систем RAG. Pinecone позволяет быстро обрабатывать большие массивы векторных данных и интегрировать поиск по смыслу в приложения.", "industry": "DB / ИИ", "location": "Сан‑Матео", "logo": "assets/logo_pinecone.svg", "email": "press@pinecone.io"},
        {"name": "Weaviate", "desc": "Weaviate — нидерландская векторная база данных с модульной архитектурой. Поддерживает интеграцию с AI-моделями для семантического поиска и работы с неструктурированными данными.", "industry": "DB / ИИ", "location": "Амстердам", "logo": "assets/logo_weaviate.svg", "email": "hello@weaviate.io"},
        {"name": "Qdrant", "desc": "Qdrant — высокопроизводительная векторная база данных с открытым исходным кодом. Оптимизирована для быстрого поиска по векторным представлениям данных и масштабирования AI-приложений.", "industry": "DB / ИИ", "location": "Берлин", "logo": "assets/logo_qdrant.svg", "email": "hello@qdrant.tech"},
    ]

    # события/посты (перевод и комментарии; ориентир по трендам — Crunchbase)
    events: List[Tuple[str, str, str]] = [
        ("OpenAI", "OpenAI завершила крупный раунд; годовой run‑rate ~ $10 млрд; 500 млн WAU. Комментарий: расширяем интеграции с экосистемой OpenAI.", "assets/news_openai_funding.svg"),
        ("Anthropic", "Anthropic усиливает линейку Claude; рост корпоративного спроса. Комментарий: фокус на безопасные сценарии.", "assets/news_anthropic_claude.svg"),
        ("xAI", "xAI ускоряет развитие продуктов с интеграцией X. Комментарий: возможности коммьюнити‑запусков.", "assets/news_xai_grok.svg"),
        ("Perplexity", "Перспективы IPO/раунда; формат ответы+источники набирает популярность. Комментарий: интересно для B2B‑аналитики.", "assets/news_perplexity_ipo.svg"),
        ("Replit", "Рассматривают IPO; усиливают ИИ‑кодинг. Комментарий: полезно для обучения и хакатонов.", "assets/news_replit_ai_coding.svg"),
        ("CoreWeave", "Взрывной рост GPU‑облака; расширение дата‑центров. Комментарий: опции для тяжёлых нагрузок.", "assets/news_coreweave_growth.svg"),
        ("Cohere", "Энтерпрайз‑LLM; спрос растёт. Комментарий: применимо для корпоративных внедрений.", "assets/news_cohere_enterprise.svg"),
        ("Glean", "Корпоративный поиск; движение к IPO. Комментарий: ускорит onboarding и знаниебазу.", "assets/news_glean_corporate.svg"),
        ("ElevenLabs", "Рост в синтезе речи и локализации. Комментарий: мультиязычные презентации и контент.", "assets/news_elevenlabs_voice.svg"),
        ("Writer", "Генеративный ИИ с упором на комплаенс. Комментарий: для отраслей с повышенной регуляцией.", "assets/news_writer_compliance.svg"),
        ("Mistral AI", "Европейские LLM становятся стандартом де‑факто в открытом сегменте. Комментарий: хорошие TCO‑метрики.", "assets/news_mistral_european.svg"),
        ("Stability AI", "Новые релизы генерации изображений/видео. Комментарий: креатив для маркетинга.", "assets/news_stability_creative.svg"),
        ("Hugging Face", "Рост экосистемы моделей и Spaces. Комментарий: централизованный хаб ИИ‑активов.", "assets/news_huggingface_ecosystem.svg"),
        ("Databricks", "Lakehouse + GenAI паттерны. Комментарий: упрощаем ML‑продукцию.", "assets/news_databricks_lakehouse.svg"),
        ("Snowflake", "Запуск фич ИИ в Data Cloud. Комментарий: единая платформа для данных и ИИ.", "assets/news_snowflake_ai_features.svg"),
        ("NVIDIA", "Новые GPU/платформы для ИИ. Комментарий: снижаем латентность инференса.", "assets/news_nvidia_gpu.svg"),
        ("Adept AI", "Агенты выполняют действия в UI. Комментарий: автоматизация рутины.", "assets/news_adept_agents.svg"),
        ("Character AI", "Рост пользовательских ассистентов. Комментарий: удержание пользователей через персонализацию.", "assets/news_character_assistants.svg"),
        ("Inflection AI", "Ассистенты для продуктивности. Комментарий: сценарии для SMB и энтерпрайза.", "assets/news_inflection_productivity.svg"),
        ("Groq", "LPU ускоряет инференс. Комментарий: real‑time демо впечатляют.", "assets/news_groq_lpu.svg"),
        ("Together AI", "Открытая инфраструктура для хостинга LLM. Комментарий: гибкая стоимость.", "assets/news_together_infrastructure.svg"),
        ("LangChain", "Новые модули и интеграции. Комментарий: быстрее прототипируем.", "assets/news_langchain_modules.svg"),
        ("LlamaIndex", "RAG паттерны крепнут. Комментарий: улучшение качества ответов.", "assets/news_llamaindex_rag.svg"),
        ("Modal", "Серверлесс для ML пайплайнов. Комментарий: экономим на DevOps.", "assets/news_modal_serverless.svg"),
        ("Runpod", "Доступные GPU для обучения/инференса. Комментарий: ускорение экспериментов.", "assets/news_runpod_gpu.svg"),
        ("n8n", "ИИ‑узлы в автоматизации. Комментарий: no‑code сценарии для команд.", "assets/news_n8n_automation.svg"),
        ("Hazy", "Синтетические данные повышают приватность. Комментарий: безопасные песочницы.", "assets/news_hazy_synthetic.svg"),
        ("Pinecone", "Векторный поиск на проде. Комментарий: масштабируем RAG.", "assets/news_pinecone_vector.svg"),
        ("Weaviate", "Модульность и плагины. Комментарий: кастомизация под домен.", "assets/news_weaviate_modular.svg"),
        ("Qdrant", "Фокус на производительность и простоту. Комментарий: предсказуемые SLA.", "assets/news_qdrant_performance.svg"),
    ]

    # Если есть внешний файл seed_companies.json — используем его вместо дефолтных
    try:
      with open('seed_companies.json', 'r', encoding='utf-8') as f:
          data = json.load(f)
          if isinstance(data, list) and data:
              companies = data
    except Exception:
      pass

    # 3) Создаём компании и посты
    name_to_id: Dict[str, int] = {}
    name_to_logo: Dict[str, str | None] = {}
    for c in companies:
        cid = _ensure_company(
            name=c["name"],
            description=c["desc"],
            industry=c["industry"],
            location=c["location"],
            logo_url=c["logo"],
            employee_count=500,  # тестовое значение
            contact_email=c["email"],
        )
        name_to_id[c["name"]] = cid
        name_to_logo[c["name"]] = c["logo"]

    # 4) Авторы: соберем существующих + добавленные фейковые
    users = _get_users()
    user_ids = [u.get("id") for u in users if isinstance(u.get("id"), int)]
    # Приоритет — наши только что созданные авторы
    if created_user_ids:
        user_ids = created_user_ids
    if not user_ids:
        user_ids = [SEED_USER_ID]

    # Идемпотентность: не создаём дубликаты постов (по паре company_id+content)
    existing_posts = _get_posts()
    existing_keys = set()
    for p in existing_posts:
        key = (p.get("company_id"), p.get("content"))
        existing_keys.add(key)

    # 5) Создаём события/посты
    for company_name, text, image_url in events:
        cid = name_to_id.get(company_name)
        if not cid:
            continue
        content = f"{company_name}: {text}"
        if (cid, content) in existing_keys:
            continue
        _create_post(
            cid,
            content_ru=content,
            image_url=image_url,
            author_user_id=_choose_author(user_ids),
        )

    print("✅ Данные по компаниям и событиям добавлены на сервер")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("❌ Ошибка при загрузке данных:", e)


