from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from passlib.hash import bcrypt
from datetime import datetime
import uuid

app = FastAPI()
engine = create_engine('sqlite:///cofound.db')
Base = declarative_base()
SessionLocal = sessionmaker(bind=engine)

# ==================== МОДЕЛИ БАЗЫ ДАННЫХ ====================

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    name = Column(String)
    phone = Column(String)
    position = Column(String)
    company_name = Column(String)
    avatar_url = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    posts = relationship("Post", back_populates="user")
    comments = relationship("Comment", back_populates="user")
    likes = relationship("Like", back_populates="user")
    business_cards = relationship("BusinessCard", back_populates="user")
    subscriptions = relationship("Subscription", back_populates="user")
    companies = relationship("Company", back_populates="created_by_user")

class Company(Base):
    __tablename__ = 'companies'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    industry = Column(String)
    location = Column(String)
    logo_url = Column(String)
    employee_count = Column(Integer)
    contact_email = Column(String)
    created_by = Column(Integer, ForeignKey('users.id'))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    created_by_user = relationship("User", back_populates="companies")
    posts = relationship("Post", back_populates="company")

class Post(Base):
    __tablename__ = 'posts'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    company_id = Column(Integer, ForeignKey('companies.id'), nullable=True)
    content = Column(Text)
    image_url = Column(String, nullable=True)
    likes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    user = relationship("User", back_populates="posts")
    company = relationship("Company", back_populates="posts")
    comments = relationship("Comment", back_populates="post")
    likes = relationship("Like", back_populates="post")

class Comment(Base):
    __tablename__ = 'comments'
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey('posts.id'))
    user_id = Column(Integer, ForeignKey('users.id'))
    content = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    post = relationship("Post", back_populates="comments")
    user = relationship("User", back_populates="comments")

class Like(Base):
    __tablename__ = 'likes'
    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey('posts.id'))
    user_id = Column(Integer, ForeignKey('users.id'))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    post = relationship("Post", back_populates="likes")
    user = relationship("User", back_populates="likes")

class BusinessCard(Base):
    __tablename__ = 'business_cards'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    name = Column(String)
    position = Column(String)
    company_name = Column(String)
    phone = Column(String)
    email = Column(String)
    social_media_link = Column(String)
    qr_code_data = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Связи
    user = relationship("User", back_populates="business_cards")

class Subscription(Base):
    __tablename__ = 'subscriptions'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    plan_type = Column(String)  # 'basic', 'advanced', 'corporate'
    start_date = Column(DateTime, default=datetime.utcnow)
    end_date = Column(DateTime)
    status = Column(String, default='active')  # 'active', 'expired', 'cancelled'
    
    # Связи
    user = relationship("User", back_populates="subscriptions")

# Избранные визитки
class FavoriteCard(Base):
    __tablename__ = 'favorite_cards'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    business_card_id = Column(Integer, ForeignKey('business_cards.id'))
    created_at = Column(DateTime, default=datetime.utcnow)

# Избранные компании
class FavoriteCompany(Base):
    __tablename__ = 'favorite_companies'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    company_id = Column(Integer, ForeignKey('companies.id'))
    created_at = Column(DateTime, default=datetime.utcnow)

# ==================== PYDANTIC МОДЕЛИ ====================

class RegisterRequest(BaseModel):
    email: str
    password: str
    name: str = None
    phone: str = None
    position: str = None
    company_name: str = None

class LoginRequest(BaseModel):
    email: str
    password: str

class UserUpdateRequest(BaseModel):
    email: str = None
    name: str = None
    phone: str = None
    position: str = None
    company_name: str = None
    avatar_url: str = None

class CompanyCreateRequest(BaseModel):
    name: str
    description: str
    industry: str
    location: str
    logo_url: str = None
    employee_count: int
    contact_email: str

class PostCreateRequest(BaseModel):
    content: str
    company_id: int = None
    image_url: str = None

class CommentCreateRequest(BaseModel):
    content: str

class BusinessCardCreateRequest(BaseModel):
    name: str
    email: str
    position: Optional[str] = None
    company_name: Optional[str] = None
    phone: Optional[str] = None
    social_media_link: Optional[str] = None

class SubscriptionCreateRequest(BaseModel):
    plan_type: str

class BusinessCardUpdateRequest(BaseModel):
    name: str = None
    position: str = None
    company_name: str = None
    phone: str = None
    email: str = None
    social_media_link: str = None

class FavoriteCreateRequest(BaseModel):
    business_card_id: int

class FavoriteCompanyCreateRequest(BaseModel):
    company_id: int

class AdminResetRequest(BaseModel):
    drop_users: bool = False
    drop_cards: bool = False
    drop_companies: bool = True
    drop_posts: bool = True
    drop_favorites: bool = True
    drop_subscriptions: bool = True

# ==================== API ЭНДПОИНТЫ ====================

@app.post('/register')
def register(req: RegisterRequest):
    db = SessionLocal()
    if db.query(User).filter(User.email == req.email).first():
        raise HTTPException(status_code=400, detail='Пользователь уже существует')
    
    user = User(
        email=req.email, 
        password_hash=bcrypt.hash(req.password),
        name=req.name,
        phone=req.phone,
        position=req.position,
        company_name=req.company_name
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    db.close()
    return {'message': 'Пользователь зарегистрирован', 'user_id': user.id}

@app.post('/login')
def login(req: LoginRequest):
    db = SessionLocal()
    user = db.query(User).filter(User.email == req.email).first()
    db.close()
    if not user or not bcrypt.verify(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail='Неверный email или пароль')
    return {'message': 'Успешный вход', 'user_id': user.id}

@app.get('/users')
def get_users():
    db = SessionLocal()
    users = db.query(User).all()
    db.close()
    return [
        {
            'id': user.id,
            'email': user.email,
            'name': user.name,
            'phone': user.phone,
            'position': user.position,
            'company_name': user.company_name,
            'avatar_url': user.avatar_url,
            'created_at': user.created_at
        }
        for user in users
    ]

@app.get('/users/{user_id}')
def get_user(user_id: int):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    db.close()
    if not user:
        raise HTTPException(status_code=404, detail='Пользователь не найден')
    return {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone,
        'position': user.position,
        'company_name': user.company_name,
        'avatar_url': user.avatar_url,
        'created_at': user.created_at
    }

@app.put('/users/{user_id}')
def update_user(user_id: int, req: UserUpdateRequest):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail='Пользователь не найден')
    
    if req.email is not None:
        # Проверим, что такой email не занят другим пользователем
        existing = db.query(User).filter(User.email == req.email, User.id != user_id).first()
        if existing:
            db.close()
            raise HTTPException(status_code=400, detail='Email уже используется')
        user.email = req.email

    if req.name is not None:
        user.name = req.name
    if req.phone is not None:
        user.phone = req.phone
    if req.position is not None:
        user.position = req.position
    if req.company_name is not None:
        user.company_name = req.company_name
    if req.avatar_url is not None:
        user.avatar_url = req.avatar_url
    
    db.commit()
    db.close()
    return {'message': 'Пользователь обновлен'}

@app.post('/companies')
def create_company(req: CompanyCreateRequest, user_id: int):
    db = SessionLocal()
    company = Company(
        name=req.name,
        description=req.description,
        industry=req.industry,
        location=req.location,
        logo_url=req.logo_url,
        employee_count=req.employee_count,
        contact_email=req.contact_email,
        created_by=user_id
    )
    db.add(company)
    db.commit()
    db.refresh(company)
    db.close()
    return {'message': 'Компания создана', 'company_id': company.id}

@app.get('/companies')
def get_companies():
    db = SessionLocal()
    companies = db.query(Company).all()
    db.close()
    return [
        {
            'id': company.id,
            'name': company.name,
            'description': company.description,
            'industry': company.industry,
            'location': company.location,
            'logo_url': company.logo_url,
            'employee_count': company.employee_count,
            'contact_email': company.contact_email,
            'created_at': company.created_at
        }
        for company in companies
    ]

@app.get('/companies/{company_id}')
def get_company(company_id: int):
    db = SessionLocal()
    company = db.query(Company).filter(Company.id == company_id).first()
    db.close()
    if not company:
        raise HTTPException(status_code=404, detail='Компания не найдена')
    return {
        'id': company.id,
        'name': company.name,
        'description': company.description,
        'industry': company.industry,
        'location': company.location,
        'logo_url': company.logo_url,
        'employee_count': company.employee_count,
        'contact_email': company.contact_email,
        'created_at': company.created_at
    }

@app.post('/posts')
def create_post(req: PostCreateRequest, user_id: int):
    db = SessionLocal()
    post = Post(
        user_id=user_id,
        company_id=req.company_id,
        content=req.content,
        image_url=req.image_url
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    db.close()
    return {'message': 'Пост создан', 'post_id': post.id}

@app.get('/posts')
def get_posts():
    db = SessionLocal()
    posts = db.query(Post).order_by(Post.created_at.desc()).all()
    db.close()
    return [
        {
            'id': post.id,
            'user_id': post.user_id,
            'company_id': post.company_id,
            'content': post.content,
            'image_url': post.image_url,
            'likes_count': post.likes_count,
            'comments_count': post.comments_count,
            'created_at': post.created_at
        }
        for post in posts
    ]

@app.post('/posts/{post_id}/comments')
def create_comment(post_id: int, req: CommentCreateRequest, user_id: int):
    db = SessionLocal()
    comment = Comment(
        post_id=post_id,
        user_id=user_id,
        content=req.content
    )
    db.add(comment)
    
    # Обновляем счетчик комментариев
    post = db.query(Post).filter(Post.id == post_id).first()
    if post:
        post.comments_count += 1
    
    db.commit()
    db.close()
    return {'message': 'Комментарий добавлен'}

@app.get('/posts/{post_id}/comments')
def get_comments(post_id: int):
    db = SessionLocal()
    comments = db.query(Comment).filter(Comment.post_id == post_id).order_by(Comment.created_at.desc()).all()
    db.close()
    return [
        {
            'id': comment.id,
            'post_id': comment.post_id,
            'user_id': comment.user_id,
            'content': comment.content,
            'created_at': comment.created_at
        }
        for comment in comments
    ]

@app.post('/posts/{post_id}/like')
def like_post(post_id: int, user_id: int):
    db = SessionLocal()
    
    # Проверяем, не лайкал ли уже пользователь этот пост
    existing_like = db.query(Like).filter(
        Like.post_id == post_id, 
        Like.user_id == user_id
    ).first()
    
    if existing_like:
        raise HTTPException(status_code=400, detail='Пост уже лайкнут')
    
    like = Like(post_id=post_id, user_id=user_id)
    db.add(like)
    
    # Обновляем счетчик лайков
    post = db.query(Post).filter(Post.id == post_id).first()
    if post:
        post.likes_count += 1
    
    db.commit()
    db.close()
    return {'message': 'Пост лайкнут'}

@app.post('/business-cards')
def create_business_card(req: BusinessCardCreateRequest, user_id: int):
    db = SessionLocal()
    business_card = BusinessCard(
        user_id=user_id,
        name=req.name,
        position=req.position or '',
        company_name=req.company_name or '',
        phone=req.phone or '',
        email=req.email,
        social_media_link=req.social_media_link or None,
        qr_code_data=f"https://cofound.app/users/{user_id}"
    )
    db.add(business_card)
    db.commit()
    db.refresh(business_card)
    db.close()
    return {'message': 'Визитка создана', 'card_id': business_card.id}

@app.put('/business-cards/{card_id}')
def update_business_card(card_id: int, req: BusinessCardUpdateRequest):
    db = SessionLocal()
    card = db.query(BusinessCard).filter(BusinessCard.id == card_id).first()
    if not card:
        db.close()
        raise HTTPException(status_code=404, detail='Визитка не найдена')

    if req.name is not None:
        card.name = req.name
    if req.position is not None:
        card.position = req.position
    if req.company_name is not None:
        card.company_name = req.company_name
    if req.phone is not None:
        card.phone = req.phone
    if req.email is not None:
        card.email = req.email
    if req.social_media_link is not None:
        card.social_media_link = req.social_media_link

    db.commit()
    db.close()
    return {'message': 'Визитка обновлена'}

@app.get('/business-cards/{user_id}')
def get_business_cards(user_id: int):
    db = SessionLocal()
    cards = db.query(BusinessCard).filter(BusinessCard.user_id == user_id).all()
    db.close()
    return [
        {
            'id': card.id,
            'name': card.name,
            'position': card.position,
            'company_name': card.company_name,
            'phone': card.phone,
            'email': card.email,
            'social_media_link': card.social_media_link,
            'qr_code_data': card.qr_code_data,
            'created_at': card.created_at
        }
        for card in cards
    ]

@app.post('/subscriptions')
def create_subscription(req: SubscriptionCreateRequest, user_id: int):
    db = SessionLocal()
    
    # Отменяем активную подписку
    active_subscription = db.query(Subscription).filter(
        Subscription.user_id == user_id,
        Subscription.status == 'active'
    ).first()
    
    if active_subscription:
        active_subscription.status = 'cancelled'
    
    # Создаем новую подписку
    from datetime import timedelta
    subscription = Subscription(
        user_id=user_id,
        plan_type=req.plan_type,
        start_date=datetime.utcnow(),
        end_date=datetime.utcnow() + timedelta(days=30),
        status='active'
    )
    db.add(subscription)
    db.commit()
    db.refresh(subscription)
    db.close()
    return {'message': 'Подписка создана', 'subscription_id': subscription.id}

# ==================== ИЗБРАННЫЕ ВИЗИТКИ ====================

@app.post('/favorites')
def add_favorite(req: FavoriteCreateRequest, user_id: int):
    db = SessionLocal()
    # проверка существования визитки
    card = db.query(BusinessCard).filter(BusinessCard.id == req.business_card_id).first()
    if not card:
        db.close()
        raise HTTPException(status_code=404, detail='Визитка не найдена')

    # не добавлять дубликаты
    exists = db.query(FavoriteCard).filter(
        FavoriteCard.user_id == user_id,
        FavoriteCard.business_card_id == req.business_card_id
    ).first()
    if exists:
        db.close()
        return {'message': 'Уже в избранном'}

    favorite = FavoriteCard(user_id=user_id, business_card_id=req.business_card_id)
    db.add(favorite)
    db.commit()
    db.refresh(favorite)
    db.close()
    return {'message': 'Добавлено в избранное', 'favorite_id': favorite.id}

@app.get('/favorites/{user_id}')
def get_favorites(user_id: int):
    db = SessionLocal()
    favorites = db.query(FavoriteCard).filter(FavoriteCard.user_id == user_id).all()
    # получить карточки
    card_ids = [f.business_card_id for f in favorites]
    cards = []
    if card_ids:
        cards = db.query(BusinessCard).filter(BusinessCard.id.in_(card_ids)).all()
    db.close()
    return [
        {
            'id': c.id,
            'user_id': c.user_id,
            'name': c.name,
            'position': c.position,
            'company_name': c.company_name,
            'phone': c.phone,
            'email': c.email,
            'social_media_link': c.social_media_link,
            'qr_code_data': c.qr_code_data,
            'created_at': c.created_at
        }
        for c in cards
    ]

@app.delete('/favorites')
def remove_favorite(user_id: int, business_card_id: int):
    db = SessionLocal()
    deleted = db.query(FavoriteCard).filter(
        FavoriteCard.user_id == user_id,
        FavoriteCard.business_card_id == business_card_id
    ).delete()
    db.commit()
    db.close()
    if deleted:
        return {'message': 'Удалено из избранного'}
    raise HTTPException(status_code=404, detail='Избранное не найдено')

# ==================== ИЗБРАННЫЕ КОМПАНИИ ====================

@app.post('/company-favorites')
def add_company_favorite(req: FavoriteCompanyCreateRequest, user_id: int):
    db = SessionLocal()
    company = db.query(Company).filter(Company.id == req.company_id).first()
    if not company:
        db.close()
        raise HTTPException(status_code=404, detail='Компания не найдена')

    exists = db.query(FavoriteCompany).filter(
        FavoriteCompany.user_id == user_id,
        FavoriteCompany.company_id == req.company_id
    ).first()
    if exists:
        db.close()
        return {'message': 'Уже в избранном'}

    favorite = FavoriteCompany(user_id=user_id, company_id=req.company_id)
    db.add(favorite)
    db.commit()
    db.refresh(favorite)
    db.close()
    return {'message': 'Добавлено в избранное', 'favorite_id': favorite.id}

@app.get('/company-favorites/{user_id}')
def get_company_favorites(user_id: int):
    db = SessionLocal()
    favorites = db.query(FavoriteCompany).filter(FavoriteCompany.user_id == user_id).all()
    company_ids = [f.company_id for f in favorites]
    companies = []
    if company_ids:
        companies = db.query(Company).filter(Company.id.in_(company_ids)).all()
    db.close()
    return [
        {
            'id': company.id,
            'name': company.name,
            'description': company.description,
            'industry': company.industry,
            'location': company.location,
            'logo_url': company.logo_url,
            'employee_count': company.employee_count,
            'contact_email': company.contact_email,
            'created_at': company.created_at,
        }
        for company in companies
    ]

@app.delete('/company-favorites')
def remove_company_favorite(user_id: int, company_id: int):
    db = SessionLocal()
    deleted = db.query(FavoriteCompany).filter(
        FavoriteCompany.user_id == user_id,
        FavoriteCompany.company_id == company_id
    ).delete()
    db.commit()
    db.close()
    if deleted:
        return {'message': 'Удалено из избранного'}
    raise HTTPException(status_code=404, detail='Избранное не найдено')

# ==================== АДМИН: СБРОС ДАННЫХ (DEV) ====================

@app.post('/admin/reset')
def admin_reset(req: AdminResetRequest):
    db = SessionLocal()
    try:
        # Удаляем в корректном порядке зависимости
        if req.drop_favorites:
            db.query(FavoriteCard).delete()
            db.query(FavoriteCompany).delete()
        if req.drop_posts:
            db.query(Like).delete()
            db.query(Comment).delete()
            db.query(Post).delete()
        if req.drop_companies:
            db.query(Company).delete()
        if req.drop_cards:
            db.query(BusinessCard).delete()
        if req.drop_subscriptions:
            db.query(Subscription).delete()
        if req.drop_users:
            db.query(User).delete()
        db.commit()
        return {"message": "Данные очищены"}
    finally:
        db.close()

# Создание всех таблиц
Base.metadata.create_all(bind=engine)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 