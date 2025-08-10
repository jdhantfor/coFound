import '../models/company.dart';
import '../services/company_service.dart';

class CompanyRepository {
  final CompanyService _companyService = CompanyService();

  // ==================== ОСНОВНЫЕ ОПЕРАЦИИ ====================

  Future<List<Company>> getCompanies() async {
    return await _companyService.getCompanies();
  }

  Future<Company?> getCompany(int id) async {
    return await _companyService.getCompany(id);
  }

  Future<Company?> createCompany({
    required int userId,
    required String name,
    required String description,
    required String industry,
    required String location,
    String? logoUrl,
    required int employeeCount,
    required String contactEmail,
  }) async {
    return await _companyService.createCompany(
      userId: userId,
      name: name,
      description: description,
      industry: industry,
      location: location,
      logoUrl: logoUrl,
      employeeCount: employeeCount,
      contactEmail: contactEmail,
    );
  }

  Future<bool> updateCompany({
    required int companyId,
    String? name,
    String? description,
    String? industry,
    String? location,
    String? logoUrl,
    int? employeeCount,
    String? contactEmail,
  }) async {
    return await _companyService.updateCompany(
      companyId: companyId,
      name: name,
      description: description,
      industry: industry,
      location: location,
      logoUrl: logoUrl,
      employeeCount: employeeCount,
      contactEmail: contactEmail,
    );
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<Company>> getCompaniesByIndustry(String industry) async {
    return await _companyService.getCompaniesByIndustry(industry);
  }

  Future<List<Company>> getCompaniesByLocation(String location) async {
    return await _companyService.getCompaniesByLocation(location);
  }

  Future<List<Company>> getCompaniesByUser(int userId) async {
    return await _companyService.getCompaniesByUser(userId);
  }

  Future<List<Company>> searchCompanies(String query) async {
    return await _companyService.searchCompanies(query);
  }

  Future<List<String>> getIndustries() async {
    return await _companyService.getIndustries();
  }

  Future<List<String>> getLocations() async {
    return await _companyService.getLocations();
  }

  Future<void> refreshCompanies() async {
    await _companyService.refreshCompanies();
  }

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<Company>> getLocalCompanies() async {
    return await _companyService.getLocalCompanies();
  }

  Future<Company?> getLocalCompany(int id) async {
    return await _companyService.getLocalCompany(id);
  }

  Future<int> saveCompanyLocally(Company company) async {
    return await _companyService.saveCompanyLocally(company);
  }

  Future<int> updateCompanyLocally(Company company) async {
    return await _companyService.updateCompanyLocally(company);
  }
} 