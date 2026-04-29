import 'package:flutter/material.dart';
import 'category.dart';

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.salary: return 'Salary';
      case Category.food: return 'Food';
      case Category.transport: return 'Transport';
      case Category.entertainment: return 'Entertainment';
      case Category.shopping: return 'Shopping';
      case Category.bills: return 'Bills';
      case Category.healthcare: return 'Healthcare';
      case Category.education: return 'Education';
      case Category.other: return 'Other';
    }
  }
  
  IconData get icon {
    switch (this) {
      case Category.salary: return Icons.work;
      case Category.food: return Icons.restaurant;
      case Category.transport: return Icons.directions_car;
      case Category.entertainment: return Icons.movie;
      case Category.shopping: return Icons.shopping_bag;
      case Category.bills: return Icons.receipt;
      case Category.healthcare: return Icons.local_hospital;
      case Category.education: return Icons.school;
      case Category.other: return Icons.category;
    }
  }
  
  Color get color {
    switch (this) {
      case Category.salary: return Colors.green;
      case Category.food: return Colors.orange;
      case Category.transport: return Colors.blue;
      case Category.entertainment: return Colors.purple;
      case Category.shopping: return Colors.pink;
      case Category.bills: return Colors.red;
      case Category.healthcare: return Colors.teal;
      case Category.education: return Colors.indigo;
      case Category.other: return Colors.grey;
    }
  }
}