import 'package:hive/hive.dart';
import '../../transactions/models/category.dart';

part 'budget.g.dart';

@HiveType(typeId: 4)
class Budget {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final Category category;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime month;
  
  @HiveField(4)
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.createdAt,
  });
}