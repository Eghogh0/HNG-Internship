import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/models/category.dart';
import '../../../transactions/models/category_extension.dart';
import '../../utils/chart_data_converter.dart';

class SpendingChart extends StatelessWidget {
  final List<Transaction> transactions;
  
  const SpendingChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final spending = ChartDataConverter.getCategorySpending(transactions);
    if (spending.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No expense data to display')),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: _buildSections(spending),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _buildSections(Map<Category, double> spending) {
    final total = spending.values.reduce((a, b) => a + b);
    
    return spending.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key.displayName}\n${percentage.toStringAsFixed(0)}%',
        color: entry.key.color,
        radius: 100,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}