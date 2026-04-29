import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../transactions/models/transaction.dart';
import '../transactions/models/category_extension.dart';

class ExportRepository {
  Future<File> generateCsv(List<Transaction> transactions) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/transactions_export.csv';
    final file = File(path);
    
    List<List<String>> rows = [
      ['Date', 'Title', 'Note', 'Category', 'Amount', 'Type']
    ];
    
    for (final tx in transactions) {
      rows.add([
        tx.date.toIso8601String(),
        tx.title,
        tx.note ?? '',
        tx.category.displayName,
        tx.amount.toString(),
        tx.isIncome ? 'Income' : 'Expense',
      ]);
    }
    
    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
    return file;
  }
  
  Future<void> shareCsv(List<Transaction> transactions) async {
    final file = await generateCsv(transactions);
    await Share.shareXFiles([XFile(file.path)], text: 'My transaction history');
  }
}