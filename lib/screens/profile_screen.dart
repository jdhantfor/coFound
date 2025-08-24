import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/feed_screen.dart';
import '/screens/companies_screen.dart';
import '/screens/qr_display_screen.dart';
import '/screens/qr_scanner_screen.dart';
import '/screens/edit_profile_screen.dart';
import '/screens/profile_settings_screen.dart';
import '/models/business_card.dart';
import '/models/user.dart';
import '/services/user_service.dart';
import '/services/business_card_service.dart';
import '/services/session_service.dart';
import '/services/company_service.dart';
import '/services/avatar_service.dart';
import '/models/company.dart';
import '/screens/company_detail_screen.dart';
import '/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  BusinessCard? _userCard;
  bool _isLoading = true;
  String? _error;
  String? _localAvatarPath;

  // Избранные визитки пользователя (с сервера)
  List<BusinessCard> _savedCards = [];
  // Избранные компании
  List<Company> _favoriteCompanies = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем избранные компании при возвращении на экран
    _refreshFavorites();
  }

  Future<void> _loadProfile() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final userId = await SessionService.getCurrentUserId();
      if (userId == null) {
        if (mounted) {
          setState(() {
            _error = 'Пользователь не авторизован';
            _isLoading = false;
          });
        }
        return;
      }

      User? user = await UserService().getUser(userId);
      user ??= await UserService().getLocalUser(userId);

      BusinessCard? card = await BusinessCardService().getCurrentUserBusinessCard(userId);
      card ??= await BusinessCardService().getLocalBusinessCard(userId);

      // Тянем избранные визитки с сервера (сервер — источник истины)
      final favorites = await BusinessCardService().getFavorites(userId);
      // Тянем избранные компании
      final favCompanies = await CompanyService().getFavoriteCompanies(userId);

      // Загружаем локальный аватар
      final localAvatarPath = await AvatarService.getLocalAvatarPath();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _userCard = card;
          _savedCards = favorites;
          _favoriteCompanies = favCompanies;
          _localAvatarPath = localAvatarPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка загрузки профиля: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _editCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          user: _currentUser!,
          businessCard: _userCard,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      setState(() {
        _userCard = result['businessCard'] ?? _userCard;
        if (result['user'] != null) {
          _currentUser = result['user'];
        }
      });
    }
  }

  void _showQRCode() async {
    // Если визитки нет – создадим минимальную на сервере и обновим профиль
    if (_userCard == null) {
      if (_currentUser == null) return;
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) return;
      // Пытаемся создать/обновить визитку на сервере
      final created = await BusinessCardService().createOrUpdateBusinessCard(
        userId: userId,
        name: _currentUser!.name ?? 'Пользователь',
        position: _currentUser!.position ?? '',
        companyName: _currentUser!.companyName ?? '',
        phone: _currentUser!.phone ?? '',
        email: _currentUser!.email,
        socialMediaLink: null,
      );
      if (created == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сначала заполните визитку в "Редактировать"')),
        );
        return;
      }
      if (mounted) {
        setState(() {
          _userCard = created;
        });
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRDisplayScreen(
          businessCard: _userCard,
          title: 'Визитная карточка',
        ),
      ),
    );
  }

  void _scanQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }

  Future<void> _refreshFavorites() async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) return;

      final favCompanies = await CompanyService().getFavoriteCompanies(userId);
      setState(() {
        _favoriteCompanies = favCompanies;
      });
    } catch (e) {
      print('Ошибка обновления избранных компаний: $e');
    }
  }

  void _removeFromFavorites(int companyId) async {
    try {
      final userId = await SessionService.getCurrentUserId();
      if (userId == null) return;

      final success = await CompanyService().removeCompanyFromFavorites(
        userId: userId,
        companyId: companyId,
      );

      if (success) {
        setState(() {
          _favoriteCompanies.removeWhere((company) => company.id == companyId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Удалено из избранного'),
              backgroundColor: AppStyles.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ошибка удаления из избранного'),
              backgroundColor: AppStyles.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppStyles.errorColor,
          ),
        );
      }
    }
  }

  void _showSubscriptionPlans() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Тарифные планы',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPlanCard('Базовый', '1 900 руб/мес', 'Просмотр до 100 компаний, импорт списков'),
                    _buildPlanCard('Продвинутый', '4 900 руб/мес', 'Экспорт данных, мониторинг до 500 компаний'),
                    _buildPlanCard('Корпоративный', 'от 10 000 руб/мес', 'Доступ к аналитике, работа в командах'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Подписка оформлена'),
                    backgroundColor: AppStyles.successColor,
                  ),
                );
              },
              style: AppStyles.elevatedButtonStyle,
              child: const Text('Выбрать тариф'),
            ),
          ],
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
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.settings, color: AppStyles.secondaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSettingsScreen(user: _currentUser!),
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadProfile, child: const Text('Повторить')),
                    ],
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Моя визитная карточка',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AvatarService.buildAvatarWidget(
                          radius: 30,
                          localPath: _localAvatarPath,
                          networkUrl: _currentUser?.avatarUrl,
                          backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                          placeholder: Icon(Icons.person, color: AppStyles.primaryColor, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_userCard?.name ?? (_currentUser?.name ?? ''), style: Theme.of(context).textTheme.headlineLarge),
                            Text(_userCard?.position ?? (_currentUser?.position ?? ''), style: Theme.of(context).textTheme.bodyMedium),
                            Text(_userCard?.companyName ?? (_currentUser?.companyName ?? ''), style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Телефон: ${_userCard?.phone ?? (_currentUser?.phone ?? '')}', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Email: ${_userCard?.email ?? (_currentUser?.email ?? '')}', style: Theme.of(context).textTheme.bodyMedium),
                    if (_userCard?.socialMediaLink != null && _userCard!.socialMediaLink!.isNotEmpty)
                      Text('Соцсети: ${_userCard!.socialMediaLink}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showQRCode,
                            style: AppStyles.elevatedButtonStyle.copyWith(
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            icon: const Icon(Icons.qr_code, size: 16),
                            label: const Text('QR-код'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _scanQRCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            icon: const Icon(Icons.qr_code_scanner, size: 16),
                            label: const Text('Сканировать'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _editCard,
                      style: AppStyles.elevatedButtonStyle.copyWith(
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      child: const Text('Редактировать'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Сохраненные визитки',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            _savedCards.isEmpty
                ? Text(
                    'Нет сохраненных визиток',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppStyles.secondaryGrey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _savedCards.length,
                    itemBuilder: (context, index) {
                      final card = _savedCards[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person, color: AppStyles.primaryColor, size: 24),
                          ),
                          title: Text(card.name, style: Theme.of(context).textTheme.headlineLarge),
                          subtitle: Text(
                            '${card.position} • ${card.companyName}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: AppStyles.secondaryGrey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRDisplayScreen(
                                  businessCard: card,
                                  title: 'Визитная карточка',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Избранные компании',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: AppStyles.primaryColor),
                  onPressed: _refreshFavorites,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _favoriteCompanies.isEmpty
                ? Text(
                    'Нет избранных компаний',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppStyles.secondaryGrey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _favoriteCompanies.length,
                    itemBuilder: (context, index) {
                      final company = _favoriteCompanies[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.business, color: AppStyles.primaryColor, size: 24),
                          ),
                          title: Text(company.name, style: Theme.of(context).textTheme.headlineLarge),
                          subtitle: Text(
                            '${company.industry} • ${company.location}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite, color: AppStyles.errorColor, size: 20),
                                onPressed: () => _removeFromFavorites(company.id),
                              ),
                              Icon(Icons.arrow_forward_ios, color: AppStyles.textColorLight),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompanyDetailScreen(companyId: company.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            Text(
              'Подписка',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showSubscriptionPlans,
              style: AppStyles.elevatedButtonStyle.copyWith(
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              child: const Text('Управление подпиской'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: AppStyles.textColorLight,
        backgroundColor: Colors.white,
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesScreen()));
              break;
            case 3:
              break; // Уже на ProfileScreen
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

  Widget _buildPlanCard(String title, String price, String description) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              price, 
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppStyles.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description, 
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}