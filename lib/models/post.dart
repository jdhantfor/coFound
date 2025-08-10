class Post {
  final int id;
  final int userId;
  final int? companyId;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    this.companyId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      companyId: json['company_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'content': content,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    int? userId,
    int? companyId,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 