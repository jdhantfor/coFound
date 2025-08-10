import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/services/qr_service.dart';
import '/models/models.dart';
import '/app_styles.dart';
import '/services/business_card_service.dart';
import '/screens/qr_display_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  String _lastScannedData = '';

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != _lastScannedData) {
        _lastScannedData = barcode.rawValue!;
        _processScannedData(barcode.rawValue!);
        break;
      }
    }
  }

  void _processScannedData(String scannedData) {
    setState(() {
      _isScanning = false;
    });

    try {
      final result = QRService.processScannedData(scannedData);
      _showScanResult(result);
    } catch (e) {
      _showError('Ошибка обработки QR-кода: $e');
    }
  }

  void _showScanResult(QRScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildResultModal(result),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isScanning = true;
    });
  }

  Widget _buildResultModal(QRScanResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getResultIcon(result.type),
                color: _getResultColor(result.type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _getResultTitle(result.type),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultContent(result),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isScanning = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Сканировать еще'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleResultAction(result),
                  style: AppStyles.elevatedButtonStyle,
                  child: Text(_getActionButtonText(result.type)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(QRScanResult result) {
    switch (result.type) {
      case QRScanType.businessCard:
        final card = result.data as BusinessCard;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: ${card.name}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Должность: ${card.position}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Компания: ${card.companyName}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Телефон: ${card.phone}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Email: ${card.email}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

      case QRScanType.user:
        final user = result.data as User;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: ${user.name}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Должность: ${user.position}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Компания: ${user.companyName}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Email: ${user.email}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

      case QRScanType.subscription:
        final subscription = result.data as Subscription;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип подписки: ${subscription.planType}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Статус: ${subscription.status}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Дата начала: ${subscription.startDate.toString().split(' ')[0]}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

      case QRScanType.url:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('URL:', style: Theme.of(context).textTheme.bodyLarge),
            Text(result.data as String, style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

      case QRScanType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Текст:', style: Theme.of(context).textTheme.bodyLarge),
            Text(result.data as String, style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

      case QRScanType.unknown:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Неизвестный формат:', style: Theme.of(context).textTheme.bodyLarge),
            Text(result.data as String, style: Theme.of(context).textTheme.bodyMedium),
          ],
        );
    }
  }

  void _handleResultAction(QRScanResult result) {
    switch (result.type) {
      case QRScanType.businessCard:
        _openBusinessCard(result);
        break;
      case QRScanType.user:
        _saveBusinessCard(result);
        break;
      case QRScanType.subscription:
        // Обработать подписку
        _handleSubscription(result);
        break;
      case QRScanType.url:
        // Открыть URL
        _openUrl(result.data as String);
        break;
      case QRScanType.text:
      case QRScanType.unknown:
        // Скопировать в буфер обмена
        _copyToClipboard(result.data as String);
        break;
    }
  }

  void _openBusinessCard(QRScanResult result) async {
    final card = result.data as BusinessCard;
    // Сохраним локально как избранное
    await BusinessCardService().saveBusinessCardLocally(card);
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRDisplayScreen(
          businessCard: card,
          title: 'Визитная карточка',
          showFavoriteButton: true,
        ),
      ),
    );
  }

  void _saveBusinessCard(QRScanResult result) {
    // TODO: Реализовать сохранение визитки в базу данных
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Визитка сохранена'),
        backgroundColor: AppStyles.successColor,
      ),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _handleSubscription(QRScanResult result) {
    // TODO: Реализовать обработку подписки
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Подписка обработана'),
        backgroundColor: AppStyles.successColor,
      ),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _openUrl(String url) {
    // TODO: Реализовать открытие URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открытие URL: $url'),
        backgroundColor: AppStyles.primaryColor,
      ),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _copyToClipboard(String text) {
    // TODO: Реализовать копирование в буфер обмена
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Текст скопирован в буфер обмена'),
        backgroundColor: AppStyles.successColor,
      ),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  IconData _getResultIcon(QRScanType type) {
    switch (type) {
      case QRScanType.businessCard:
      case QRScanType.user:
        return Icons.person;
      case QRScanType.subscription:
        return Icons.card_membership;
      case QRScanType.url:
        return Icons.link;
      case QRScanType.text:
        return Icons.text_fields;
      case QRScanType.unknown:
        return Icons.help;
    }
  }

  Color _getResultColor(QRScanType type) {
    switch (type) {
      case QRScanType.businessCard:
      case QRScanType.user:
        return AppStyles.primaryColor;
      case QRScanType.subscription:
        return Colors.orange;
      case QRScanType.url:
        return Colors.blue;
      case QRScanType.text:
        return Colors.green;
      case QRScanType.unknown:
        return Colors.grey;
    }
  }

  String _getResultTitle(QRScanType type) {
    switch (type) {
      case QRScanType.businessCard:
        return 'Визитная карточка';
      case QRScanType.user:
        return 'Пользователь';
      case QRScanType.subscription:
        return 'Подписка';
      case QRScanType.url:
        return 'Ссылка';
      case QRScanType.text:
        return 'Текст';
      case QRScanType.unknown:
        return 'Неизвестный формат';
    }
  }

  String _getActionButtonText(QRScanType type) {
    switch (type) {
      case QRScanType.businessCard:
      case QRScanType.user:
        return 'Сохранить';
      case QRScanType.subscription:
        return 'Активировать';
      case QRScanType.url:
        return 'Открыть';
      case QRScanType.text:
      case QRScanType.unknown:
        return 'Копировать';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Сканирование QR-кода'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Оверлей с рамкой для сканирования
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Инструкции
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Наведите камеру на QR-код',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 