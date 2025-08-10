import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageUtils {
  static ImageProvider getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/icon.png');
    }
    
    // Если это локальный файл (начинается с assets/)
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    }
    
    // Если это сетевой URL, используем NetworkImage
    return NetworkImage(imageUrl);
  }
  
  static Widget buildImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder ?? const Icon(Icons.image, color: Colors.grey);
    }
    
    // Если это локальный файл
    if (imageUrl.startsWith('assets/')) {
      // Проверяем, является ли файл SVG
      if (imageUrl.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (context) => placeholder ?? const Center(child: CircularProgressIndicator()),
        );
      } else {
        // Для других форматов используем обычный Image.asset
        return Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
          },
        );
      }
    }
    
    // Если это сетевой URL
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => placeholder ?? const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey);
        },
      );
    }
  }
}
