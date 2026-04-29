import 'package:flutter/material.dart';
import '../features/task_manager/ui/task_list_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/tasks':
        return MaterialPageRoute(builder: (_) => const TaskListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}