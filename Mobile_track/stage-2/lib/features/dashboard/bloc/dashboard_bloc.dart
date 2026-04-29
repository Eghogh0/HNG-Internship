import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../transactions/models/transaction.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionRepository _repository = TransactionRepository();
  
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }
  
  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final transactions = _repository.getAllTransactions();
      final balance = _calculateBalance(transactions);
      final totalIncome = _calculateTotalIncome(transactions);
      final totalExpense = _calculateTotalExpense(transactions);
      emit(DashboardLoaded(
        transactions: transactions,
        balance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
  
  double _calculateBalance(List<Transaction> transactions) {
    double balance = 0;
    for (final tx in transactions) {
      if (tx.isIncome) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }
  
  double _calculateTotalIncome(List<Transaction> transactions) {
    return transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  }
  
  double _calculateTotalExpense(List<Transaction> transactions) {
    return transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);
  }
}