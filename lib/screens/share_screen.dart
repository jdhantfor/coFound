import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/models/models.dart';
import '/app_styles.dart';
import '/utils/image_utils.dart';

class ShareScreen extends StatefulWidget {
  final Post post;
  final User? author;
  final Company? company;

  const ShareScreen({
    super.key,
    required this.post,
    this.author,
    this.company,
  });

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _selectedTarget = 'wall';
  bool _isSharing = false;

  final List<Map<String, dynamic>> _shareTargets = [
    {
      'id': 'wall',
      'title': 'Моя стена',
      'description': 'Опубликовать на своей стене',
      'icon': Icons.home,
    },
    {
      'id': 'telegram',
      'title': 'Telegram',
      'description': 'Поделиться в Telegram',
      'icon': Icons.send,
    },
    {
      'id': 'whatsapp',
      'title': 'WhatsApp',
      'description': 'Поделиться в WhatsApp',
      'icon': Icons.chat,
    },
    {
      'id': 'email',
      'title': 'Email',
      'description': 'Отправить по email',
      'icon': Icons.email,
    },
  ];

  Future<void> _sharePost() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final postText = _buildShareText();
      
      switch (_selectedTarget) {
        case 'wall':
          // TODO: Реализовать публикацию на стене
          await Future.delayed(const Duration(seconds: 1));
          break;
        case 'telegram':
          await _shareToTelegram(postText);
          break;
        case 'whatsapp':
          await _shareToWhatsApp(postText);
          break;
        case 'email':
          await _shareToEmail(postText);
          break;
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Публикация успешно поделена'),
            backgroundColor: AppStyles.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _buildShareText() {
    final authorName = widget.author?.name ?? 'Пользователь';
    final companyName = widget.company?.name ?? '';
    final content = widget.post.content;
    
    String text = '$authorName';
    if (companyName.isNotEmpty) {
      text += ' из $companyName';
    }
    text += ':\n\n$content\n\n';
    text += 'Поделено через coFound';
    
    return text;
  }

  Future<void> _shareToTelegram(String text) async {
    final url = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent('https://cofound.app')}&text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Не удалось открыть Telegram');
    }
  }

  Future<void> _shareToWhatsApp(String text) async {
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Не удалось открыть WhatsApp');
    }
  }

  Future<void> _shareToEmail(String text) async {
    final url = Uri.parse('mailto:?subject=Публикация из coFound&body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Не удалось открыть почтовое приложение');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppStyles.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'coFound',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Предварительный просмотр поста
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Предварительный просмотр',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                      child: widget.author?.avatarUrl != null
                          ? ClipOval(
                              child: ImageUtils.buildImage(
                                imageUrl: widget.author!.avatarUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorWidget: Icon(Icons.person, color: AppStyles.primaryColor, size: 20),
                              ),
                            )
                          : Icon(Icons.person, color: AppStyles.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.author?.name ?? 'Пользователь',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.company != null)
                            Text(
                              widget.company!.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppStyles.secondaryGrey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.post.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Выбор цели для шаринга
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _shareTargets.length,
              itemBuilder: (context, index) {
                final target = _shareTargets[index];
                final isSelected = _selectedTarget == target['id'];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected ? AppStyles.primaryColor.withOpacity(0.1) : Colors.white,
                  child: RadioListTile<String>(
                    value: target['id'],
                    groupValue: _selectedTarget,
                    onChanged: (value) {
                      setState(() {
                        _selectedTarget = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Icon(
                          target['icon'],
                          color: isSelected ? AppStyles.primaryColor : AppStyles.secondaryGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                target['title'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppStyles.primaryColor : null,
                                ),
                              ),
                              Text(
                                target['description'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppStyles.secondaryGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),
          
          // Кнопка поделиться
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSharing ? null : _sharePost,
                style: AppStyles.elevatedButtonStyle,
                child: _isSharing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Поделиться'),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 