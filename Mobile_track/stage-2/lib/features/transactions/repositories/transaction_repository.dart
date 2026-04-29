import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionRepository {
  late Box<Transaction> _transactionBox;
  
  Future<void> initialize() async {
    _transactionBox = await Hive.openBox<Transaction>('transactions');
  }
  
  List<Transaction> getAllTransactions() {
    return _transactionBox.values.toList();
  }
  
  Future<void> saveTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }
  
  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }
  
  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final transactions = getAllTransactions();
    final List<Transaction> newTransactions = [];
    
    for (final tx in transactions.where((t) => t.recurrence != null)) {
      final schedule = tx.recurrence!.toSchedule();
      if (schedule.occursOn(now) && 
          (tx.lastProcessedDate == null || !_isSameDay(tx.lastProcessedDate!, now))) {
        
        final newTx = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: tx.title,
          note: tx.note,
          amount: tx.amount,
          category: tx.category,
          date: now,
          isIncome: tx.isIncome,
          recurrence: tx.recurrence,
          lastProcessedDate: now,
        );
        newTransactions.add(newTx);
        
        final updatedTx = Transaction(
          id: tx.id,
          title: tx.title,
          note: tx.note,
          amount: tx.amount,
          category: tx.category,
          date: tx.date,
          isIncome: tx.isIncome,
          recurrence: tx.recurrence,
          lastProcessedDate: now,
        );
        await saveTransaction(updatedTx);
      }
    }
    
    for (final tx in newTransactions) {
      await saveTransaction(tx);
    }
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}