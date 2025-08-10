import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import './app_styles.dart';
import 'test_feed_widget.dart';

void main() {
  runApp(const CoFoundApp());
}

class CoFoundApp extends StatelessWidget {
  const CoFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'coFound',
      theme: AppStyles.theme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}