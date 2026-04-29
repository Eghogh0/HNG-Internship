import 'package:hive/hive.dart';

part 'category.g.dart';   // This tells Hive to generate category.g.dart

@HiveType(typeId: 1)
enum Category {
  @HiveField(0)
  salary,
  @HiveField(1)
  food,
  @HiveField(2)
  transport,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  shopping,
  @HiveField(5)
  bills,
  @HiveField(6)
  healthcare,
  @HiveField(7)
  education,
  @HiveField(8)
  other,
}