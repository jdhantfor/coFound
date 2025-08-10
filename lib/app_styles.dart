import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color primaryColor = Color(0xFF6065E8); // Основной синий
  static const Color secondaryColor = Color(0xFFD33D3D); // Красный
  static const Color tertiaryColor = Color(0xFF6065E8); // Синий для градиентов
  static const Color errorColor = Color(0xFFD33D3D); // Красный для ошибок
  static const Color successColor = Color(0xFF4CAF50); // Зеленый для успеха
  static const Color textColor = Color(0xFF000000); // Черный текст
  static const Color textColorLight = Color(0xFF666666); // Светло-серый текст
  static const Color fieldBackgroundColor = Color(0xFFFFFFFF); // Белый фон полей
  static const Color backgroundColor = Color(0xFFFFFFFF); // Белый фон
  static const Color secondaryGrey = Color(0xFF757575);
  static const Color actionButtonRed = Color(0xFFD33D3D); // Красный для кнопок
  static const Color actionButtonGreen = Color(0xFF4CAF50); // Зеленый для кнопок
  static const Color actionButtonBlue = Color(0xFF6065E8); // Синий для кнопок

  // Theme
  static final ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Roboto',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: Colors.black87,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: secondaryGrey,
      ),
      titleSmall: TextStyle(
        fontSize: 10,
        color: secondaryGrey,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: errorColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: fieldBackgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle,
    ),
  );

  // Button Styles
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 8,
    shadowColor: primaryColor.withOpacity(0.4),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle redButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 8,
    shadowColor: secondaryColor.withOpacity(0.4),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    minimumSize: const Size(double.infinity, 48),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  // Text Field Styles
  static InputDecoration defaultTextFieldDecoration({
    required String hintText,
    bool hasError = false,
    bool isFocused = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: secondaryGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: fieldBackgroundColor,
    );
  }

  static const TextStyle textFieldTextStyle = TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontSize: 12,
    color: errorColor,
  );
}