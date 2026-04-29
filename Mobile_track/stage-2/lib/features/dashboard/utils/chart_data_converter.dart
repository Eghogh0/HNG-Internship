import '../../transactions/models/transaction.dart';
import '../../transactions/models/category.dart';

class ChartDataConverter {
  static Map<Category, double> getCategorySpending(List<Transaction> transactions) {
    final Map<Category, double> spending = {};
    for (final tx in transactions.where((t) => !t.isIncome)) {
      spending[tx.category] = (spending[tx.category] ?? 0) + tx.amount;
    }
    return spending;
  }
}