import 'package:flutter/material.dart';
import 'export_repository.dart';
import '../transactions/repositories/transaction_repository.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.file_download, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text('Export your transactions as CSV', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final repo = TransactionRepository();
                await repo.initialize();
                final transactions = repo.getAllTransactions();
                final exportRepo = ExportRepository();
                await exportRepo.shareCsv(transactions);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export shared successfully!')),
                  );
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Export & Share CSV'),
            ),
          ],
        ),
      ),
    );
  }
}