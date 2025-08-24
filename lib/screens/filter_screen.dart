import 'package:flutter/material.dart';
import '../repositories/repositories.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const FilterScreen({
    super.key,
    this.currentFilters,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  
  // Фильтры
  String? _selectedIndustry;
  String? _selectedLocation;
  String? _searchQuery;
  String? _employeeCountFilter;
  
  // Списки для выбора
  List<String> _industries = [];
  List<String> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _loadCurrentFilters();
  }

  Future<void> _loadFilterOptions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final companyRepository = CompanyRepository();
      _industries = await companyRepository.getIndustries();
      _locations = await companyRepository.getLocations();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки фильтров: $e')),
      );
    }
  }

  void _loadCurrentFilters() {
    if (widget.currentFilters != null) {
      _selectedIndustry = widget.currentFilters!['industry'];
      _selectedLocation = widget.currentFilters!['location'];
      _searchQuery = widget.currentFilters!['search'];
      _employeeCountFilter = widget.currentFilters!['employeeCount'];
      
      // Устанавливаем значение в контроллер поиска
      if (_searchQuery != null) {
        _searchController.text = _searchQuery!;
      }
    }
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      final filters = {
        'industry': _selectedIndustry,
        'location': _selectedLocation,
        'search': _searchQuery,
        'employeeCount': _employeeCountFilter,
      };

      Navigator.pop(context, filters);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedIndustry = null;
      _selectedLocation = null;
      _searchQuery = null;
      _employeeCountFilter = null;
      _searchController.clear();
    });
  }

  void _resetFilters() {
    _clearFilters();
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              _clearFilters();
              Navigator.pop(context, null);
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSearchSection(),
                  const SizedBox(height: 24),
                  _buildIndustrySection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildEmployeeCountSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Поиск',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Название компании, описание...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value.isEmpty ? null : value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustrySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Индустрия',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedIndustry,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Выберите индустрию'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все индустрии'),
                ),
                ..._industries.map((industry) => DropdownMenuItem<String>(
                  value: industry,
                  child: Text(industry),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedIndustry = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Локация',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Выберите локацию'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все локации'),
                ),
                ..._locations.map((location) => DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCountSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Количество сотрудников',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _employeeCountFilter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Выберите размер компании'),
              items: const [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('Любой размер'),
                ),
                DropdownMenuItem<String>(
                  value: '1-10',
                  child: Text('1-10 сотрудников'),
                ),
                DropdownMenuItem<String>(
                  value: '11-50',
                  child: Text('11-50 сотрудников'),
                ),
                DropdownMenuItem<String>(
                  value: '51-200',
                  child: Text('51-200 сотрудников'),
                ),
                DropdownMenuItem<String>(
                  value: '201-1000',
                  child: Text('201-1000 сотрудников'),
                ),
                DropdownMenuItem<String>(
                  value: '1000+',
                  child: Text('1000+ сотрудников'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _employeeCountFilter = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetFilters,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Сбросить'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Применить'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}