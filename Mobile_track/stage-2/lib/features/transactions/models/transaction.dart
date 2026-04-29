import 'package:hive/hive.dart';
import 'category.dart';
import 'recurrence.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? note;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final Category category;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final bool isIncome;
  
  @HiveField(7)
  final Recurrence? recurrence;
  
  @HiveField(8)
  final DateTime? lastProcessedDate;

  Transaction({
    required this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    this.recurrence,
    this.lastProcessedDate,
  });
}