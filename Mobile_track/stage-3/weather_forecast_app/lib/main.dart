import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'screens/home_screen.dart';

void main() {
  setPathUrlStrategy();   // removes the '#' from web URLs
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}