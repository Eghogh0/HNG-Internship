import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/recurrence.dart';
import '../repositories/transaction_repository.dart';
import 'widgets/category_selector.dart';
import 'widgets/recurring_input.dart';
import '../../../core/utils/app_constants.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  
  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _isIncome = true;
  Category _selectedCategory = Category.food;
  DateTime _selectedDate = DateTime.now();
  Recurrence? _recurrence;
  
  final TransactionRepository _repository = TransactionRepository();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _noteController.text = widget.transaction!.note ?? '';
      _amountController.text = widget.transaction!.amount.toString();
      _isIncome = widget.transaction!.isIncome;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _recurrence = widget.transaction!.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        isIncome: _isIncome,
        recurrence: _recurrence,
        lastProcessedDate: widget.transaction?.lastProcessedDate,
      );
      await _repository.saveTransaction(transaction);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Income'), icon: Icon(Icons.arrow_upward)),
                ButtonSegment(value: false, label: Text('Expense'), icon: Icon(Icons.arrow_downward)),
              ],
              selected: {_isIncome},
              onSelectionChanged: (set) => setState(() => _isIncome = set.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (${AppConstants.currencySymbol})', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 12),
            RecurringInput(
              onRecurrenceSelected: (rec) => setState(() => _recurrence = rec),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}