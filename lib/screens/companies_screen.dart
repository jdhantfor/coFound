import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/feed_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/company_detail_screen.dart';
import '/screens/filter_screen.dart';
import '/repositories/repositories.dart';
import '/models/models.dart';
import '/services/services.dart';
import '/services/session_service.dart';
import '/app_styles.dart';
import '/utils/image_utils.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  List<Company> _companies = [];
  List<Company> _filteredCompanies = [];
  List<Company> _favoriteCompanies = [];
  bool _isLoading = true;
  String? _error;
  
  // Фильтры
  Map<String, dynamic>? _currentFilters;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем избранные компании при возвращении на экран
    _refreshFavorites();
  }

  Future<void> _loadCompanies() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final companies = await CompanyRepository().getCompanies();
      
      // Загружаем избранные компании
      final userId = await SessionService.getCurrentUserId();
      List<Company> favorites = [];
      if (userId != null) {
        favorites = await CompanyService().getFavoriteCompanies(userId);
      }
      
      if (mounted) {
        setState(() {
          _companies = companies;
          _filteredCompanies = companies;
          _favoriteCompanies = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки компаний: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyFilters(Map<String, dynamic>? filters) async {
    if (filters == null) {
      // Сброс фильтров
      if (mounted) {
        setState(() {
          _filteredCompanies = _companies;
          _currentFilters = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _currentFilters = filters;
      });
    }

    try {
      List<Company> filtered = _companies;

      // Поиск по тексту
      final searchQuery = filters['search'];
      if (searchQuery != null && searchQuery.toString().isNotEmpty) {
        final searchResults = await CompanyRepository().searchCompanies(searchQuery);
        filtered = filtered.where((company) => 
          searchResults.any((result) => result.id == company.id)
        ).toList();
      }

      // Фильтр по индустрии
      if (filters['industry'] != null) {
        filtered = filtered.where((company) => 
          company.industry == filters['industry']
        ).toList();
      }

      // Фильтр по локации
      if (filters['location'] != null) {
        filtered = filtered.where((company) => 
          company.location == filters['location']
        ).toList();
      }

      // Фильтр по количеству сотрудников
      if (filters['employeeCount'] != null) {
        filtered = filtered.where((company) {
          final employeeCount = company.employeeCount ?? 0;
          switch (filters['employeeCount']) {
            case '1-10':
              return employeeCount >= 1 && employeeCount <= 10;
            case '11-50':
              return employeeCount >= 11 && employeeCount <= 50;
            case '51-200':
              return employeeCount >= 51 && employeeCount <= 200;
            case '201-1000':
              return employeeCount >= 201 && employeeCount <= 1000;
            case '1000+':
              return employeeCount > 1000;
            default:
              return true;
          }
        }).toList();
      }

      if (mounted) {
        setState(() {
          _filteredCompanies = filtered;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка применения фильтров: $e')),
      );
      }
    }
  }

  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(currentFilters: _currentFilters),
      ),
    );

    if (mounted) {
      await _applyFilters(result);
    }
  }

  void _openCompanyDetails(Company company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDetailScreen(
          companyId: company.id,
          companyName: company.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppStyles.primaryColor, width: 1),
          ),
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'co',
                  style: TextStyle(
                    color: Color(0xFFD33D3D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Found',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppStyles.secondaryColor),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildCompaniesList(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: AppStyles.textColorLight,
        backgroundColor: Colors.white,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()));
              break;
            case 2:
              break; // Уже на CompaniesScreen
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Лента',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Компании',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCompanies,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompaniesList() {
    if (_filteredCompanies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: AppStyles.secondaryGrey,
            ),
            const SizedBox(height: 16),
            Text(
              _currentFilters != null ? 'Компании не найдены' : 'Нет компаний',
              style: TextStyle(
                fontSize: 18,
                color: AppStyles.secondaryGrey,
              ),
            ),
            if (_currentFilters != null) ...[
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить фильтры',
                style: TextStyle(
                  fontSize: 14,
                  color: AppStyles.secondaryGrey,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCompanies.length,
      itemBuilder: (context, index) {
        final company = _filteredCompanies[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? ClipOval(
                      child: ImageUtils.buildImage(
                        imageUrl: company.logoUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: Icon(Icons.business, color: AppStyles.primaryColor, size: 24),
                      ),
                    )
                  : Icon(Icons.business, color: AppStyles.primaryColor, size: 24),
            ),
            title: Text(
              company.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${company.industry} • ${company.location}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (company.employeeCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${company.employeeCount} сотрудников',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isCompanyFavorite(company.id) ? Icons.favorite : Icons.favorite_border,
                    color: _isCompanyFavorite(company.id) ? AppStyles.errorColor : AppStyles.secondaryGrey,
                    size: 20,
                  ),
                  onPressed: () => _toggleFavorite(company),
                ),
                Icon(Icons.arrow_forward_ios, color: AppStyles.secondaryGrey),
              ],
            ),
            onTap: () => _openCompanyDetails(company),
          ),
        );
      },
    );
  }

  Future<void> _refreshFavorites() async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) return;

      final favorites = await CompanyService().getFavoriteCompanies(userId);
      setState(() {
        _favoriteCompanies = favorites;
      });
    } catch (e) {
      print('Ошибка обновления избранных компаний: $e');
    }
  }

  bool _isCompanyFavorite(int companyId) {
    return _favoriteCompanies.any((company) => company.id == companyId);
  }

  Future<void> _toggleFavorite(Company company) async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Необходимо войти в систему')),
        );
        return;
      }

      final isFavorite = _isCompanyFavorite(company.id);
      
      if (isFavorite) {
        // Удаляем из избранного
        final success = await CompanyService().removeCompanyFromFavorites(
          userId: userId,
          companyId: company.id,
        );
        
        if (success) {
          setState(() {
            _favoriteCompanies.removeWhere((c) => c.id == company.id);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Удалено из избранного'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Добавляем в избранное
        final success = await CompanyService().addCompanyToFavorites(
          userId: userId,
          companyId: company.id,
        );
        
        if (success) {
          setState(() {
            _favoriteCompanies.add(company);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Добавлено в избранное'),
              backgroundColor: AppStyles.successColor,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppStyles.errorColor,
        ),
      );
    }
  }
}