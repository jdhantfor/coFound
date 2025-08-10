class BusinessProposal {
  final String id;
  final String companyName;
  final String title;
  final String description;
  final String industry;
  final String location;
  final String logoUrl;
  final List<String> tags;
  final int employeeCount;
  final String contactEmail;
  final String collaborationType; // Форма сотрудничества: партнерство, инвестиции, обмен опытом
  final DateTime createdAt; // Дата создания для сортировки/аналитики

  BusinessProposal({
    required this.id,
    required this.companyName,
    required this.title,
    required this.description,
    required this.industry,
    required this.location,
    required this.logoUrl,
    required this.tags,
    required this.employeeCount,
    required this.contactEmail,
    required this.collaborationType,
    required this.createdAt,
  });
}