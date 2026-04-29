import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/transactions/models/transaction.dart';
import 'features/transactions/models/category.dart';
import 'features/transactions/models/recurrence.dart';
import 'features/budget/models/budget.dart';
import 'features/transactions/repositories/transaction_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters – ensure unique typeIds
  Hive.registerAdapter(TransactionAdapter());   // typeId 0
  Hive.registerAdapter(CategoryAdapter());      // typeId 1
  Hive.registerAdapter(RecurrenceAdapter());    // typeId 2
  Hive.registerAdapter(RecurrenceTypeAdapter());// typeId 5 (changed)
  Hive.registerAdapter(BudgetAdapter());        // typeId 4
  
  final transactionRepo = TransactionRepository();
  await transactionRepo.initialize();
  await transactionRepo.processRecurringTransactions();
  
  runApp(const ExpenseTrackerApp());
}