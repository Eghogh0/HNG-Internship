import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../models/category_extension.dart';
import 'package:expense_tracker/features/transactions/ui/add_edit_transaction_screen.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.category.color.withAlpha((0.2 * 255).round()),
          child: Icon(transaction.category.icon, color: transaction.category.color),
        ),
        title: Text(transaction.title),
        subtitle: Text('${transaction.category.displayName} • ${_formatDate(transaction.date)}'),
        trailing: Text(
          '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          final navigator = Navigator.of(context);
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(transaction: transaction),
            ),
          ).then((result) {
            if (result == true) {
              navigator.pop(true);
            }
          });
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}