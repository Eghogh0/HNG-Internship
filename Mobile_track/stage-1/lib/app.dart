import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

class SmartUtilityApp extends StatelessWidget {
  const SmartUtilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Utility Toolkit',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const HomeScreen(),
    );
  }
}