import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../app_styles.dart';
import '../utils/image_utils.dart';
import '../services/session_service.dart';
import '../services/avatar_service.dart';
import '../screens/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final User user;

  const ProfileSettingsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _profilePublic = true;
  bool _showEmail = true;
  bool _showPhone = true;
  String _selectedLanguage = 'Русский';
  String _selectedTheme = 'Системная';
  String? _localAvatarPath;
  bool _isLoadingAvatar = false;

  // Тестовые данные статистики
  final Map<String, int> _activityStats = {
    'Просмотры профиля': 156,
    'Сохраненные визитки': 23,
    'Отправленные сообщения': 8,
    'QR-коды отсканированы': 12,
  };

  // Тестовая история действий
  final List<Map<String, dynamic>> _actionHistory = [
    {
      'action': 'Обновил профиль',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'icon': Icons.edit,
    },
    {
      'action': 'Отсканировал QR-код',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'icon': Icons.qr_code_scanner,
    },
    {
      'action': 'Сохранил визитку',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.save,
    },
    {
      'action': 'Создал QR-код',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.qr_code,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalAvatar();
  }

  Future<void> _loadLocalAvatar() async {
    final localPath = await AvatarService.getLocalAvatarPath();
    setState(() {
      _localAvatarPath = localPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки профиля'),
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildActivityStatsSection(),
            const SizedBox(height: 24),
            _buildActionHistorySection(),
            const SizedBox(height: 24),
            _buildPrivacySettingsSection(),
            const SizedBox(height: 24),
            _buildAppSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    AvatarService.buildAvatarWidget(
                      radius: 40,
                      localPath: _localAvatarPath,
                      networkUrl: widget.user.avatarUrl,
                      backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                      placeholder: Icon(
                        Icons.person,
                        size: 40,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                    if (_isLoadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name ?? 'Без имени',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        widget.user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _changeAvatar,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Изменить фото'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeAvatar,
                    icon: const Icon(Icons.delete),
                    label: const Text('Удалить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика активности',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...(_activityStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ),
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionHistorySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'История действий',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...(_actionHistory.map((action) => ListTile(
              leading: Icon(
                action['icon'],
                color: AppStyles.primaryColor,
              ),
              title: Text(action['action']),
              subtitle: Text(_formatTime(action['time'])),
              contentPadding: EdgeInsets.zero,
            ))),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _viewFullHistory,
                child: const Text('Посмотреть полную историю'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки приватности',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Публичный профиль'),
              subtitle: const Text('Другие пользователи могут видеть ваш профиль'),
              value: _profilePublic,
              onChanged: (value) {
                setState(() {
                  _profilePublic = value;
                });
              },
              activeColor: AppStyles.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Показывать email'),
              subtitle: const Text('Отображать email в визитке'),
              value: _showEmail,
              onChanged: (value) {
                setState(() {
                  _showEmail = value;
                });
              },
              activeColor: AppStyles.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Показывать телефон'),
              subtitle: const Text('Отображать телефон в визитке'),
              value: _showPhone,
              onChanged: (value) {
                setState(() {
                  _showPhone = value;
                });
              },
              activeColor: AppStyles.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки приложения',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Уведомления'),
              subtitle: const Text('Получать push-уведомления'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppStyles.primaryColor,
            ),
            ListTile(
              title: const Text('Язык'),
              subtitle: Text(_selectedLanguage),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectLanguage,
            ),
            ListTile(
              title: const Text('Тема'),
              subtitle: Text(_selectedTheme),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTheme,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Экспорт данных'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _deleteAccount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Удалить аккаунт'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Выйти из аккаунта'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }

  // ==================== ACTION METHODS ====================

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите источник', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoadingAvatar = true;
    });

    try {
      final imageFile = await AvatarService.takePhotoWithCamera();
      if (imageFile != null) {
        await _processSelectedImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при съемке фото: $e'),
          backgroundColor: AppStyles.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoadingAvatar = true;
    });

    try {
      final imageFile = await AvatarService.pickImageFromGallery();
      if (imageFile != null) {
        await _processSelectedImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выборе изображения: $e'),
          backgroundColor: AppStyles.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  Future<void> _processSelectedImage(File imageFile) async {
    try {
      // Сохраняем локально
      final localPath = await AvatarService.saveAvatarLocally(imageFile);
      if (localPath != null) {
        setState(() {
          _localAvatarPath = localPath;
        });

        // Загружаем на сервер
        final userId = await SessionService.getCurrentUserId();
        if (userId != null) {
          final avatarUrl = await AvatarService.uploadAvatarToServer(imageFile, userId);
          if (avatarUrl != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Аватар успешно обновлен'),
                backgroundColor: AppStyles.successColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при обработке изображения: $e'),
          backgroundColor: AppStyles.errorColor,
        ),
      );
    }
  }

  void _removeAvatar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фото'),
        content: const Text('Вы уверены, что хотите удалить фото профиля?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAvatar();
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAvatar() async {
    try {
      await AvatarService.deleteAvatar();
      setState(() {
        _localAvatarPath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото профиля удалено'),
          backgroundColor: AppStyles.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении фото: $e'),
          backgroundColor: AppStyles.errorColor,
        ),
      );
    }
  }

  void _viewFullHistory() {
    // TODO: Navigate to full history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Полная история будет добавлена')),
    );
  }

  void _selectLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите язык', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...(['Русский', 'English', '中文', 'Español'].map((language) => ListTile(
              title: Text(language),
              trailing: _selectedLanguage == language ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = language;
                });
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  void _selectTheme() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите тему', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...(['Системная', 'Светлая', 'Темная'].map((theme) => ListTile(
              title: Text(theme),
              trailing: _selectedTheme == theme ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _selectedTheme = theme;
                });
                Navigator.pop(context);
              },
            ))),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Экспорт данных будет добавлен')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт'),
        content: const Text('Это действие нельзя отменить. Все ваши данные будут удалены навсегда.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Удаление аккаунта будет добавлено')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await SessionService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
} 