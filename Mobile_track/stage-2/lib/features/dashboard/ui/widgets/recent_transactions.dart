import 'package:flutter/material.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/ui/widgets/transaction_card.dart';

class RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  
  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No transactions yet')),
        ),
      );
    }
    
    return Column(
      children: transactions.map((tx) => TransactionCard(transaction: tx)).toList(),
    );
  }
}