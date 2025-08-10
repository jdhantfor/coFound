class Company {
  final int id;
  final String name;
  final String description;
  final String industry;
  final String location;
  final String? logoUrl;
  final int? employeeCount;
  final String contactEmail;
  final int? createdBy;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.location,
    this.logoUrl,
    required this.employeeCount,
    required this.contactEmail,
    required this.createdBy,
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      industry: json['industry'] as String,
      location: json['location'] as String,
      logoUrl: json['logo_url'] as String?,
      employeeCount: (json['employee_count'] is int)
          ? json['employee_count'] as int
          : (json['employee_count'] == null
              ? null
              : int.tryParse(json['employee_count'].toString())),
      contactEmail: json['contact_email'] as String,
      createdBy: (json['created_by'] is int)
          ? json['created_by'] as int
          : (json['created_by'] == null
              ? null
              : int.tryParse(json['created_by'].toString())),
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'industry': industry,
      'location': location,
      'logo_url': logoUrl,
      'employee_count': employeeCount ?? 0,
      'contact_email': contactEmail,
      'created_by': createdBy ?? 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Company copyWith({
    int? id,
    String? name,
    String? description,
    String? industry,
    String? location,
    String? logoUrl,
    int? employeeCount,
    String? contactEmail,
    int? createdBy,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      employeeCount: employeeCount ?? this.employeeCount,
      contactEmail: contactEmail ?? this.contactEmail,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 