import 'package:equatable/equatable.dart';
import '../../transactions/models/transaction.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Transaction> transactions;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  
  const DashboardLoaded({
    required this.transactions,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });
  
  @override
  List<Object?> get props => [transactions, balance, totalIncome, totalExpense];
}

class DashboardError extends DashboardState {
  final String message;
  
  const DashboardError({required this.message});
  
  @override
  List<Object?> get props => [message];
}