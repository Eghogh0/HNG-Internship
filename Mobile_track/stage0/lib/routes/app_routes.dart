import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text("Route not found")),
      ),
    );
  }
}