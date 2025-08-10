import 'package:dio/dio.dart';
import '../models/company.dart';
import 'database_helper.dart';

class CompanyService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Dio _dio = Dio();
  final String _baseUrl = 'http://62.113.37.96:8000';

  // ==================== ЛОКАЛЬНЫЕ ОПЕРАЦИИ ====================

  Future<List<Company>> getLocalCompanies() async {
    return await _databaseHelper.getAllCompanies();
  }

  Future<Company?> getLocalCompany(int id) async {
    return await _databaseHelper.getCompany(id);
  }

  Future<int> saveCompanyLocally(Company company) async {
    return await _databaseHelper.insertCompany(company);
  }

  Future<int> updateCompanyLocally(Company company) async {
    return await _databaseHelper.updateCompany(company);
  }

  // ==================== СЕТЕВЫЕ ОПЕРАЦИИ ====================

  Future<List<Company>> getCompanies() async {
    try {
      final response = await _dio.get('$_baseUrl/companies');

      if (response.statusCode == 200) {
        final List<dynamic> companiesData = response.data;
        final List<Company> companies = companiesData.map((json) => Company.fromJson(json)).toList();

        // Сохраняем компании локально
        for (final company in companies) {
          await saveCompanyLocally(company);
        }

        return companies;
      }
    } catch (e) {
      print('Ошибка получения компаний: $e');
      // Возвращаем локальные данные
      return await getLocalCompanies();
    }
    return [];
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
    try {
      final response = await _dio.post(
        '$_baseUrl/companies',
        data: {
          'name': name,
          'description': description,
          'industry': industry,
          'location': location,
          'logo_url': logoUrl,
          'employee_count': employeeCount,
          'contact_email': contactEmail,
        },
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final companyId = response.data['company_id'];
        final company = Company(
          id: companyId,
          name: name,
          description: description,
          industry: industry,
          location: location,
          logoUrl: logoUrl,
          employeeCount: employeeCount,
          contactEmail: contactEmail,
          createdBy: userId,
          createdAt: DateTime.now(),
        );

        // Сохраняем компанию локально
        await saveCompanyLocally(company);
        return company;
      }
    } catch (e) {
      print('Ошибка создания компании: $e');
      rethrow;
    }
    return null;
  }

  Future<Company?> getCompany(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/companies/$id');

      if (response.statusCode == 200) {
        final company = Company.fromJson(response.data);
        
        // Сохраняем компанию локально
        await saveCompanyLocally(company);
        return company;
      }
    } catch (e) {
      print('Ошибка получения компании: $e');
      // Пробуем получить из локальной БД
      return await getLocalCompany(id);
    }
    return null;
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
    try {
      final response = await _dio.put(
        '$_baseUrl/companies/$companyId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (industry != null) 'industry': industry,
          if (location != null) 'location': location,
          if (logoUrl != null) 'logo_url': logoUrl,
          if (employeeCount != null) 'employee_count': employeeCount,
          if (contactEmail != null) 'contact_email': contactEmail,
        },
      );

      if (response.statusCode == 200) {
        // Обновляем локальную копию
        final localCompany = await getLocalCompany(companyId);
        if (localCompany != null) {
          final updatedCompany = localCompany.copyWith(
            name: name,
            description: description,
            industry: industry,
            location: location,
            logoUrl: logoUrl,
            employeeCount: employeeCount,
            contactEmail: contactEmail,
          );
          await updateCompanyLocally(updatedCompany);
        }
        return true;
      }
    } catch (e) {
      print('Ошибка обновления компании: $e');
      return false;
    }
    return false;
  }

  // ==================== ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ ====================

  Future<List<Company>> getCompaniesByIndustry(String industry) async {
    final allCompanies = await getLocalCompanies();
    return allCompanies.where((company) => company.industry.toLowerCase().contains(industry.toLowerCase())).toList();
  }

  Future<List<Company>> getCompaniesByLocation(String location) async {
    final allCompanies = await getLocalCompanies();
    return allCompanies.where((company) => company.location.toLowerCase().contains(location.toLowerCase())).toList();
  }

  Future<List<Company>> getCompaniesByUser(int userId) async {
    final allCompanies = await getLocalCompanies();
    return allCompanies.where((company) => company.createdBy == userId).toList();
  }

  Future<List<Company>> searchCompanies(String query) async {
    final allCompanies = await getLocalCompanies();
    return allCompanies.where((company) {
      return company.name.toLowerCase().contains(query.toLowerCase()) ||
             company.description.toLowerCase().contains(query.toLowerCase()) ||
             company.industry.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<String>> getIndustries() async {
    final allCompanies = await getLocalCompanies();
    final industries = allCompanies.map((company) => company.industry).toSet().toList();
    return industries..sort();
  }

  Future<List<String>> getLocations() async {
    final allCompanies = await getLocalCompanies();
    final locations = allCompanies.map((company) => company.location).toSet().toList();
    return locations..sort();
  }

  Future<void> refreshCompanies() async {
    // Обновляем компании с сервера
    await getCompanies();
  }

  // ==================== ИЗБРАННЫЕ КОМПАНИИ (СЕРВЕР) ====================

  Future<bool> addCompanyToFavorites({required int userId, required int companyId}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/company-favorites',
        queryParameters: { 'user_id': userId },
        data: { 'company_id': companyId },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка добавления компании в избранное: $e');
      return false;
    }
  }

  Future<bool> removeCompanyFromFavorites({required int userId, required int companyId}) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/company-favorites',
        queryParameters: { 'user_id': userId, 'company_id': companyId },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка удаления компании из избранного: $e');
      return false;
    }
  }

  Future<List<Company>> getFavoriteCompanies(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl/company-favorites/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<Company> companies = data.map((json) => Company.fromJson(json)).toList();
        // опционально обновим локальный кеш
        for (final c in companies) {
          await saveCompanyLocally(c);
        }
        return companies;
      }
    } catch (e) {
      print('Ошибка получения избранных компаний: $e');
    }
    return [];
  }
} 