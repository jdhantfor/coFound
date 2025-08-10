import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_card.dart';
import '../models/user.dart';
import '../services/business_card_service.dart';
import '../services/user_service.dart';
import '../services/sync_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final BusinessCard? businessCard;

  const EditProfileScreen({
    Key? key,
    required this.user,
    this.businessCard,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessCardService = BusinessCardService();
  final _userService = UserService();
  final _syncService = SyncService();
  
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _companyNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _socialMediaController;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.businessCard?.name ?? widget.user.name ?? '');
    _positionController = TextEditingController(text: widget.businessCard?.position ?? '');
    _companyNameController = TextEditingController(text: widget.businessCard?.companyName ?? '');
    _phoneController = TextEditingController(text: widget.businessCard?.phone ?? '');
    _emailController = TextEditingController(text: widget.businessCard?.email ?? widget.user.email ?? '');
    _socialMediaController = TextEditingController(text: widget.businessCard?.socialMediaLink ?? '');

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _positionController.addListener(_onFieldChanged);
    _companyNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _socialMediaController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create or update business card
      final businessCard = await _businessCardService.createOrUpdateBusinessCard(
        userId: widget.user.id!,
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        companyName: _companyNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        socialMediaLink: _socialMediaController.text.trim().isEmpty 
            ? null 
            : _socialMediaController.text.trim(),
      );

      // Update user data if name or email changed
      User? updatedUser;
      if (widget.user.name != _nameController.text.trim() || 
          widget.user.email != _emailController.text.trim()) {
        await _userService.updateUser(
          userId: widget.user.id!,
          name: _nameController.text.trim(),
        );
        updatedUser = widget.user.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
      }

      // Notify other screens about the changes
      if (businessCard != null) {
        _syncService.notifyBusinessCardUpdate(businessCard);
      }
      if (updatedUser != null) {
        _syncService.notifyUserUpdate(updatedUser);
      }

      setState(() {
        _hasChanges = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return updated data
        Navigator.pop(context, {
          'user': updatedUser ?? widget.user,
          'businessCard': businessCard,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при сохранении: ${e.toString()}';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имя обязательно для заполнения';
    }
    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email обязателен для заполнения';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }

  String? _validateSocialMedia(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Social media is optional
    }
    if (!value.trim().startsWith('http://') && !value.trim().startsWith('https://')) {
      return 'Ссылка должна начинаться с http:// или https://';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          if (_hasChanges && !_isLoading)
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Основная информация',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Имя *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: _validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _positionController,
                              decoration: const InputDecoration(
                                labelText: 'Должность',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _companyNameController,
                              decoration: const InputDecoration(
                                labelText: 'Название компании',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Контактная информация',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Телефон',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _socialMediaController,
                              decoration: const InputDecoration(
                                labelText: 'Социальные сети',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.link),
                                hintText: 'https://example.com',
                              ),
                              validator: _validateSocialMedia,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton.icon(
                      onPressed: _hasChanges ? _saveChanges : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить изменения'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    OutlinedButton.icon(
                      onPressed: () {
                        _nameController.text = widget.businessCard?.name ?? widget.user.name ?? '';
                        _positionController.text = widget.businessCard?.position ?? '';
                        _companyNameController.text = widget.businessCard?.companyName ?? '';
                        _phoneController.text = widget.businessCard?.phone ?? '';
                        _emailController.text = widget.businessCard?.email ?? widget.user.email ?? '';
                        _socialMediaController.text = widget.businessCard?.socialMediaLink ?? '';
                        
                        setState(() {
                          _hasChanges = false;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Сбросить изменения'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 