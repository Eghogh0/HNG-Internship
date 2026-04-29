import 'package:hive/hive.dart';
import '../models/budget.dart';
import '../../transactions/models/category.dart';

class BudgetRepository {
  late Box<Budget> _budgetBox;
  
  Future<void> initialize() async {
    _budgetBox = await Hive.openBox<Budget>('budgets');
  }
  
  List<Budget> getAllBudgets() {
    return _budgetBox.values.toList();
  }
  
  Future<void> saveBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
  }
  
  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
  }
  
  Budget? getBudgetForCategory(Category category, DateTime month) {
    try {
      return _budgetBox.values.firstWhere(
        (b) => b.category == category && 
               b.month.year == month.year && 
               b.month.month == month.month,
      );
    } catch (e) {
      return null;
    }
  }
}