class BusinessCard {
  final int id;
  final int userId;
  final String name;
  final String position;
  final String companyName;
  final String phone;
  final String email;
  final String? socialMediaLink;
  final String? qrCodeData;
  final DateTime createdAt;

  BusinessCard({
    required this.id,
    required this.userId,
    required this.name,
    required this.position,
    required this.companyName,
    required this.phone,
    required this.email,
    this.socialMediaLink,
    this.qrCodeData,
    required this.createdAt,
  });

  // Создание из JSON
  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      position: json['position'] as String,
      companyName: json['company_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      socialMediaLink: json['social_media_link'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'position': position,
      'company_name': companyName,
      'phone': phone,
      'email': email,
      'social_media_link': socialMediaLink,
      'qr_code_data': qrCodeData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Копирование с изменениями
  BusinessCard copyWith({
    int? id,
    int? userId,
    String? name,
    String? position,
    String? companyName,
    String? phone,
    String? email,
    String? socialMediaLink,
    String? qrCodeData,
    DateTime? createdAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      position: position ?? this.position,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      socialMediaLink: socialMediaLink ?? this.socialMediaLink,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessCard &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.position == position &&
        other.companyName == companyName &&
        other.phone == phone &&
        other.email == email &&
        other.socialMediaLink == socialMediaLink &&
        other.qrCodeData == qrCodeData &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        position.hashCode ^
        companyName.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        socialMediaLink.hashCode ^
        qrCodeData.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'BusinessCard(id: $id, userId: $userId, name: $name, position: $position, companyName: $companyName, phone: $phone, email: $email, socialMediaLink: $socialMediaLink, qrCodeData: $qrCodeData, createdAt: $createdAt)';
  }
} 