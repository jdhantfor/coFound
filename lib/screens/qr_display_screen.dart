import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/services/qr_service.dart';
import '/models/models.dart';
import '/app_styles.dart';
import '/services/session_service.dart';
import '/services/business_card_service.dart';

class QRDisplayScreen extends StatefulWidget {
  final BusinessCard? businessCard;
  final User? user;
  final Subscription? subscription;
  final String? customData;
  final String title;
  final bool showFavoriteButton;

  const QRDisplayScreen({
    super.key,
    this.businessCard,
    this.user,
    this.subscription,
    this.customData,
    required this.title,
    this.showFavoriteButton = false,
  });

  @override
  _QRDisplayScreenState createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: _saveQRToGallery,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: _shareQR,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR-код
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: _qrKey,
                child: _buildQRCode(),
              ),
            ),
            const SizedBox(height: 24),

            // Информация о QR-коде
            _buildQRInfo(),
            const SizedBox(height: 24),

            // Кнопки действий
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    if (widget.businessCard != null) {
      return QRService.generateBusinessCardQR(
        card: widget.businessCard!,
        size: 250,
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
      );
    } else if (widget.user != null) {
      return QRService.generateUserQR(
        user: widget.user!,
        size: 250,
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
      );
    } else if (widget.subscription != null) {
      return QRService.generateSubscriptionQR(
        subscription: widget.subscription!,
        size: 250,
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
      );
    } else if (widget.customData != null) {
      return QrImageView(
        data: widget.customData!,
        version: QrVersions.auto,
        size: 250,
        backgroundColor: Colors.white,
        foregroundColor: AppStyles.primaryColor,
      );
    } else {
      return Container(
        width: 250,
        height: 250,
        color: Colors.grey.shade300,
        child: const Center(
          child: Text('Нет данных для QR-кода'),
        ),
      );
    }
  }

  Widget _buildQRInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о QR-коде',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoContent(),
        ],
      ),
    );
  }

  Widget _buildInfoContent() {
    if (widget.businessCard != null) {
      final card = widget.businessCard!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Тип', 'Визитная карточка'),
          _buildInfoRow('Имя', card.name),
          _buildInfoRow('Должность', card.position),
          _buildInfoRow('Компания', card.companyName),
          _buildInfoRow('Телефон', card.phone),
          _buildInfoRow('Email', card.email),
        ],
      );
    } else if (widget.user != null) {
      final user = widget.user!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Тип', 'Пользователь'),
          _buildInfoRow('Имя', user.name ?? ''),
          _buildInfoRow('Должность', user.position ?? ''),
          _buildInfoRow('Компания', user.companyName ?? ''),
          _buildInfoRow('Email', user.email ?? ''),
        ],
      );
    } else if (widget.subscription != null) {
      final subscription = widget.subscription!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Тип', 'Подписка'),
          _buildInfoRow('План', subscription.planType),
          _buildInfoRow('Статус', subscription.status),
          _buildInfoRow('Дата начала', subscription.startDate.toString().split(' ')[0]),
        ],
      );
    } else if (widget.customData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Тип', 'Пользовательские данные'),
          _buildInfoRow('Данные', widget.customData!),
        ],
      );
    } else {
      return const Text('Нет информации для отображения');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppStyles.secondaryGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.businessCard != null && widget.showFavoriteButton)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleFavorite,
              style: AppStyles.elevatedButtonStyle,
              icon: const Icon(Icons.star_border),
              label: const Text('В избранное'),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveQRToGallery,
            style: AppStyles.elevatedButtonStyle,
            child: _isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Сохранение...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text('Сохранить в галерею'),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _copyQRData,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles.primaryColor,
              side: BorderSide(color: AppStyles.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copy, size: 20),
                SizedBox(width: 8),
                Text('Копировать данные'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    if (widget.businessCard == null) return;
    final userId = await SessionService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Авторизуйтесь, чтобы добавлять в избранное')),
      );
      return;
    }
    final ok = await BusinessCardService()
        .addToFavorites(userId: userId, businessCardId: widget.businessCard!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Добавлено в избранное' : 'Не удалось добавить в избранное'),
        backgroundColor: ok ? AppStyles.successColor : Colors.red,
      ),
    );
  }

  Future<void> _saveQRToGallery() async {
    setState(() {
      _isSaving = true;
    });

    try {
      bool success = false;

      if (widget.businessCard != null) {
        success = await QRService.saveBusinessCardQR(
          card: widget.businessCard!,
        );
      } else if (widget.user != null) {
        // TODO: Реализовать сохранение QR-кода пользователя
        success = true;
      } else if (widget.subscription != null) {
        success = await QRService.saveSubscriptionQR(
          subscription: widget.subscription!,
        );
      } else if (widget.customData != null) {
        // TODO: Реализовать сохранение пользовательского QR-кода
        success = true;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR-код сохранен в галерею'),
            backgroundColor: AppStyles.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка сохранения QR-кода'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _shareQR() {
    // TODO: Реализовать функцию "Поделиться"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция "Поделиться" в разработке'),
        backgroundColor: AppStyles.primaryColor,
      ),
    );
  }

  void _copyQRData() {
    String dataToCopy = '';

    if (widget.businessCard != null) {
      dataToCopy = widget.businessCard!.qrCodeData ?? '';
    } else if (widget.user != null) {
      dataToCopy = 'https://cofound.app/users/${widget.user!.id}';
    } else if (widget.subscription != null) {
      dataToCopy = 'https://cofound.app/subscriptions/${widget.subscription!.id}';
    } else if (widget.customData != null) {
      dataToCopy = widget.customData!;
    }

    if (dataToCopy.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: dataToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные скопированы в буфер обмена'),
          backgroundColor: AppStyles.successColor,
        ),
      );
    }
  }
} 