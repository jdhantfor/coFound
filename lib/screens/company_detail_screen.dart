import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../app_styles.dart';
import '../utils/image_utils.dart';

class CompanyDetailScreen extends StatefulWidget {
  final int companyId;
  final String? companyName;

  const CompanyDetailScreen({
    super.key,
    required this.companyId,
    this.companyName,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  Company? _company;
  List<Post> _companyPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Загружаем данные компании
      final company = await CompanyRepository().getCompany(widget.companyId);
      
      // Загружаем посты компании
      final posts = await PostRepository().getPostsByCompany(widget.companyId);

      setState(() {
        _company = company;
        _companyPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки данных: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_company?.name ?? widget.companyName ?? 'Компания'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildCompanyContent(),
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
            onPressed: _loadCompanyData,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyContent() {
    if (_company == null) {
      return const Center(child: Text('Компания не найдена'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanyHeader(),
          const SizedBox(height: 24),
          _buildCompanyInfo(),
          const SizedBox(height: 24),
          _buildCompanyStats(),
          const SizedBox(height: 24),
          _buildCompanyPosts(),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: ImageUtils.getImageProvider(_company!.logoUrl),
              child: _company!.logoUrl == null
                  ? const Icon(Icons.business, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _company!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_company!.industry != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _company!.industry!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (_company!.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _company!.location!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'О компании',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_company!.description != null)
              Text(
                _company!.description!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            const SizedBox(height: 16),
            if (_company!.contactEmail != null) ...[
              _buildInfoRow(Icons.email, 'Email', _company!.contactEmail!),
              const SizedBox(height: 8),
            ],
            if (_company!.employeeCount != null) ...[
              _buildInfoRow(
                Icons.people,
                'Сотрудников',
                '${_company!.employeeCount}',
              ),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(
              Icons.calendar_today,
              'Дата создания',
              _formatDate(_company!.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyStats() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Постов',
                    '${_companyPosts.length}',
                    Icons.article,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Лайков',
                    '${_companyPosts.fold(0, (sum, post) => sum + post.likesCount)}',
                    Icons.favorite,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Комментариев',
                    '${_companyPosts.fold(0, (sum, post) => sum + post.commentsCount)}',
                    Icons.comment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppStyles.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Посты компании',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_companyPosts.length} постов',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_companyPosts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'У компании пока нет постов',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _companyPosts.length,
            itemBuilder: (context, index) {
              final post = _companyPosts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: ImageUtils.getImageProvider(post.imageUrl),
                    child: post.imageUrl == null
                        ? const Icon(Icons.image)
                        : null,
                  ),
                  title: Text(
                    post.content.length > 50
                        ? '${post.content.substring(0, 50)}...'
                        : post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDate(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${post.likesCount}'),
                      const SizedBox(width: 8),
                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${post.commentsCount}'),
                    ],
                  ),
                  onTap: () {
                    // TODO: Навигация к детальной странице поста
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
} 