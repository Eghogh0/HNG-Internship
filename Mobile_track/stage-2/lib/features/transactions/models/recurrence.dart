import 'package:hive/hive.dart';
import 'package:schedules/schedules.dart';

part 'recurrence.g.dart';

@HiveType(typeId: 2)  // ✅ Class Recurrence uses typeId 2 (was 2, keep it)
class Recurrence {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final RecurrenceType type;
  
  @HiveField(2)
  final int frequency;
  
  @HiveField(3)
  final List<int>? weekdays;
  
  @HiveField(4)
  final List<int>? monthDays;
  
  @HiveField(5)
  final DateTime startDate;

  Recurrence({
    required this.id,
    required this.type,
    required this.frequency,
    this.weekdays,
    this.monthDays,
    required this.startDate,
  });
  
  Schedule toSchedule() {
    switch (type) {
      case RecurrenceType.daily:
        return Daily(startDate: startDate, frequency: frequency);
      case RecurrenceType.weekly:
        return Weekly(
          startDate: startDate,
          frequency: frequency,
          weekdays: weekdays ?? [DateTime.monday],
        );
      case RecurrenceType.monthly:
        return Monthly(
          startDate: startDate,
          frequency: frequency,
          days: monthDays ?? [1],
        );
      case RecurrenceType.yearly:
        return Yearly(startDate: startDate, frequency: frequency);
    }
  }
}

@HiveType(typeId: 5)  // ✅ Enum RecurrenceType uses typeId 5 (was 3, changed to avoid conflict)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.daily: return 'Daily';
      case RecurrenceType.weekly: return 'Weekly';
      case RecurrenceType.monthly: return 'Monthly';
      case RecurrenceType.yearly: return 'Yearly';
    }
  }
}