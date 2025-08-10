import 'package:flutter/material.dart';
import '/screens/feed_screen.dart';
import '/screens/companies_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/filter_screen.dart';
import '/services/business_proposal.dart';
import '/services/company_service.dart';
import '/services/session_service.dart';
import '/models/company.dart';
import '/app_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentIndex = 0;
  int _viewedCount = 0;
  int _favoritesCount = 0;
  bool _isSwiping = false; // Флаг для предотвращения множественных свайпов

  // Фильтры
  Map<String, dynamic>? _appliedFilters;
  final List<String> _favoriteIndustries = [];

  // Тестовые данные
  final List<BusinessProposal> _allProposals = [
    BusinessProposal(
      id: '1',
      companyName: 'TechStart',
      title: 'Ищем IT-партнера для разработки',
      description: 'Стартап в сфере финтех ищет опытного разработчика для создания мобильного приложения.',
      industry: 'Финтех',
      location: 'Москва',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Flutter', 'Firebase', 'Стартап'],
      employeeCount: 5,
      contactEmail: 'info@techstart.ru',
      collaborationType: 'Партнерство',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '2',
      companyName: 'GreenEco',
      title: 'Партнерство в экологических проектах',
      description: 'Компания по переработке отходов ищет партнеров для расширения сети.',
      industry: 'Экология',
      location: 'Санкт-Петербург',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Экология', 'Переработка', 'Франшиза'],
      employeeCount: 25,
      contactEmail: 'partners@greeneco.ru',
      collaborationType: 'Франшиза',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '3',
      companyName: 'FoodDelivery',
      title: 'Требуется логистический партнер',
      description: 'Сервис доставки еды ищет партнера для организации складской логистики.',
      industry: 'Доставка еды',
      location: 'Казань',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Логистика', 'Доставка', 'Склад'],
      employeeCount: 15,
      contactEmail: 'logistics@fooddelivery.ru',
      collaborationType: 'Партнерство',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '4',
      companyName: 'EduPlatform',
      title: 'Ищем партнера для онлайн-образования',
      description: 'Платформа онлайн-курсов ищет партнера для создания контента и маркетинга.',
      industry: 'Образование',
      location: 'Екатеринбург',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['EdTech', 'Онлайн-курсы', 'Маркетинг'],
      employeeCount: 12,
      contactEmail: 'contact@eduplatform.ru',
      collaborationType: 'Инвестиции',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '5',
      companyName: 'HealthTech',
      title: 'Партнер для медицинского стартапа',
      description: 'Разработка телемедицинского сервиса, ищем инвесторов и разработчиков.',
      industry: 'Здравоохранение',
      location: 'Новосибирск',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Телемедицина', 'AI', 'Стартап'],
      employeeCount: 8,
      contactEmail: 'info@healthtech.ru',
      collaborationType: 'Инвестиции',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '6',
      companyName: 'RetailBoost',
      title: 'Партнер для расширения розничной сети',
      description: 'Компания розничной торговли ищет партнера для открытия новых магазинов.',
      industry: 'Розничная торговля',
      location: 'Ростов-на-Дону',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Розница', 'Франшиза', 'Продажи'],
      employeeCount: 30,
      contactEmail: 'info@retailboost.ru',
      collaborationType: 'Франшиза',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '7',
      companyName: 'TravelHub',
      title: 'Ищем партнера для туристического стартапа',
      description: 'Платформа для бронирования туров ищет разработчиков и инвесторов.',
      industry: 'Туризм',
      location: 'Сочи',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Туризм', 'Бронирование', 'Стартап'],
      employeeCount: 10,
      contactEmail: 'contact@travelhub.ru',
      collaborationType: 'Партнерство',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '8',
      companyName: 'Rooby',
      title: 'Ищем партнера для полетного стартапа',
      description: 'Платформа для бронирования туров ищет разработчиков и инвесторов.',
      industry: 'Туризм',
      location: 'Африка',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Туризм', 'Бронирование', 'Стартап'],
      employeeCount: 10,
      contactEmail: 'contact@travelhub.ru',
      collaborationType: 'Партнерство',
      createdAt: DateTime.now(),
    ),
    BusinessProposal(
      id: '9',
      companyName: 'РГСУ',
      title: 'Ищем партнера для научного стартапа',
      description: 'Институт университетского колледжа.',
      industry: 'Наука',
      location: 'Москва',
      logoUrl: 'https://via.placeholder.com/80',
      tags: ['Наука', 'Иннополис', 'Стартап'],
      employeeCount: 10,
      contactEmail: 'contact@nauchpop.ru',
      collaborationType: 'Партнерство',
      createdAt: DateTime.now(),
    ),
  ];

  List<BusinessProposal> get _proposals {
    if (_appliedFilters == null) return _allProposals;
    return _allProposals.where((proposal) {
      final locationMatch = _appliedFilters!['location'] == 'Все' || proposal.location == _appliedFilters!['location'];
      final industryMatch = _appliedFilters!['industry'] == 'Все' || proposal.industry == _appliedFilters!['industry'];
      final typeMatch = _appliedFilters!['collaborationType'] == 'Все' || proposal.collaborationType == _appliedFilters!['collaborationType'];
      return locationMatch && industryMatch && typeMatch;
    }).toList();
  }

  // (зарезервировано под рекомендации)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    if (_currentIndex < _proposals.length - 1 && !_isSwiping) {
      print('Swiping left, currentIndex: $_currentIndex');
      _isSwiping = true;
      _animateCard(const Offset(-1.5, 0), () {
        _nextCard();
        _isSwiping = false;
      });
    }
  }

  void _onSwipeRight() async {
    if (_currentIndex < _proposals.length && !_isSwiping) {
      print('Swiping right, currentIndex: $_currentIndex');
      _isSwiping = true;
      final proposal = _proposals[_currentIndex];
      // Попытка найти companyId по имени из локального кеша
      // Обновим список компаний с сервера и попробуем найти по имени
      await CompanyService().getCompanies();
      final companies = await CompanyService().getLocalCompanies();
      Company? matched;
      for (final c in companies) {
        if (c.name.toLowerCase() == proposal.companyName.toLowerCase()) {
          matched = c;
          break;
        }
      }
      final userId = await SessionService.getCurrentUserId();
      if (userId != null) {
        // Если не нашли точного совпадения — поищем по contains
        if (matched == null) {
          for (final c in companies) {
            if (c.name.toLowerCase().contains(proposal.companyName.toLowerCase()) ||
                proposal.companyName.toLowerCase().contains(c.name.toLowerCase())) {
              matched = c;
              break;
            }
          }
        }

        // Если всё ещё нет компании — создадим её на сервере
        if (matched == null) {
          try {
            final created = await CompanyService().createCompany(
              userId: userId,
              name: proposal.companyName,
              description: proposal.description,
              industry: proposal.industry,
              location: proposal.location,
              logoUrl: proposal.logoUrl.isNotEmpty ? proposal.logoUrl : null,
              employeeCount: proposal.employeeCount,
              contactEmail: proposal.contactEmail,
            );
            if (created != null) {
              matched = created;
            }
          } catch (_) {}
        }

        if (matched != null) {
          await CompanyService().addCompanyToFavorites(userId: userId, companyId: matched.id);
        }
      }
      setState(() {
        _favoritesCount++;
        _favoriteIndustries.add(proposal.industry);
      });
      _animateCard(const Offset(1.5, 0), () {
        _nextCard();
        _isSwiping = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Добавлено в избранное'),
          backgroundColor: AppStyles.successColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _animateCard(Offset endOffset, VoidCallback onComplete) {
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward().then((_) {
      onComplete();
      _animationController.reset();
    });
  }

  void _nextCard() {
    if (_currentIndex < _proposals.length - 1) {
      setState(() {
        _currentIndex++;
        _viewedCount++;
        print('Next card, new index: $_currentIndex, viewed: $_viewedCount');
      });
    } else {
      setState(() {
        _currentIndex = _proposals.length; // перейти в состояние пустого экрана
      });
    }
  }

  // (пустой экран заменяет диалог по окончанию)

  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FilterScreen()),
    );
    if (result != null) {
      setState(() {
        _appliedFilters = result;
        _currentIndex = 0;
        _viewedCount = 0;
      });
      if (result['saveFilter']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Фильтр сохранен'),
            backgroundColor: AppStyles.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Исправлено: всегда показываем основной список карточек, не фильтруем по _recommendedProposals
    final proposalsToShow = _proposals;

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
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
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppStyles.secondaryColor),
            onPressed: _openFilters,
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppStyles.secondaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Уведомления в разработке'),
                  backgroundColor: AppStyles.errorColor,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Просмотрено: $_viewedCount',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Избранное: $_favoritesCount',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: AppStyles.secondaryColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: proposalsToShow.isNotEmpty ? (_currentIndex + 1) / proposalsToShow.length : 0,
                  backgroundColor: AppStyles.textColorLight.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                ),
              ],
            ),
          ),
          if (_favoriteIndustries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Рекомендации для вас',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          Expanded(
            child: _currentIndex < proposalsToShow.length
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_currentIndex + 1 < proposalsToShow.length)
                        Positioned(
                          top: 20,
                          child: Transform.scale(
                            scale: 0.95,
                            child: _buildProposalCard(proposalsToShow[_currentIndex + 1], isBackground: true),
                          ),
                        ),
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          if (!_isSwiping) {
                            final delta = details.delta.dx / MediaQuery.of(context).size.width;
                            setState(() {
                              _slideAnimation = Tween<Offset>(
                                begin: Offset.zero,
                                end: Offset(delta * 1.5, 0),
                              ).animate(_animationController);
                            });
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          print('Drag end, velocity: ${details.velocity.pixelsPerSecond.dx}, currentIndex: $_currentIndex');
                          if (!_isSwiping) {
                            if (details.velocity.pixelsPerSecond.dx > 500) {
                              _onSwipeRight();
                            } else if (details.velocity.pixelsPerSecond.dx < -500) {
                              _onSwipeLeft();
                            } else {
                              _animationController.reverse().then((_) {
                                setState(() {
                                  _slideAnimation = Tween<Offset>(
                                    begin: Offset.zero,
                                    end: Offset.zero,
                                  ).animate(_animationController);
                                });
                              });
                            }
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _slideAnimation.value * MediaQuery.of(context).size.width,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildProposalCard(proposalsToShow[_currentIndex]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет доступных предложений',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppStyles.secondaryGrey),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 0;
                              _viewedCount = 0;
                            });
                          },
                          child: const Text('Начать заново'),
                        )
                      ],
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  color: AppStyles.actionButtonRed,
                  onPressed: _currentIndex < proposalsToShow.length ? _onSwipeLeft : null,
                ),
                _buildActionButton(
                  icon: Icons.info_outline,
                  color: AppStyles.actionButtonBlue,
                  onPressed: _currentIndex < proposalsToShow.length ? () { _showProposalDetails(proposalsToShow[_currentIndex]); } : null,
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: AppStyles.secondaryColor,
                  onPressed: _currentIndex < proposalsToShow.length ? _onSwipeRight : null,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: AppStyles.textColorLight,
        backgroundColor: Colors.white,
        currentIndex: 0,
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

  Widget _buildProposalCard(BusinessProposal proposal, {bool isBackground = false}) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width - 32,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isBackground ? 0.05 : 0.1),
            blurRadius: isBackground ? 5 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppStyles.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppStyles.secondaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.companyName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        '${proposal.industry} • ${proposal.location}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              proposal.title,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                proposal.description,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.5, fontSize: 13),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: proposal.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppStyles.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: AppStyles.secondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppStyles.textColorLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${proposal.employeeCount} сотрудников',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  void _showProposalDetails(BusinessProposal proposal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Подробная информация',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 18),
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Компания:', proposal.companyName),
                      _buildDetailRow('Отрасль:', proposal.industry),
                      _buildDetailRow('Местоположение:', proposal.location),
                      _buildDetailRow('Сотрудников:', '${proposal.employeeCount}'),
                      _buildDetailRow('Email:', proposal.contactEmail),
                      _buildDetailRow('Форма сотрудничества:', proposal.collaborationType),
                      const SizedBox(height: 16),
                      Text(
                        'Описание:',
                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        proposal.description,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onSwipeRight();
                      },
                      style: AppStyles.elevatedButtonStyle.copyWith(
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      child: const Text('В избранное'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Функция связи в разработке'),
                            backgroundColor: AppStyles.errorColor,
                          ),
                        );
                      },
                      style: AppStyles.outlinedButtonStyle.copyWith(
                        foregroundColor: WidgetStateProperty.all(AppStyles.primaryColor),
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      child: const Text('Связаться'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}