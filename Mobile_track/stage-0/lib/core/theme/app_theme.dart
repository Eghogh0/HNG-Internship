import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}