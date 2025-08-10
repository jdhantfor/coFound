class Subscription {
  final int id;
  final int userId;
  final String planType; // 'basic', 'advanced', 'corporate'
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled'

  Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      planType: json['plan_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
    };
  }

  Subscription copyWith({
    int? id,
    int? userId,
    String? planType,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  bool get isExpired => DateTime.now().isAfter(endDate);
} 