import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'widgets/balance_card.dart';
import 'widgets/spending_chart.dart';
import 'widgets/recent_transactions.dart';
import '../../transactions/ui/add_edit_transaction_screen.dart';
import '../../auth/liveness_verification/liveness_screen.dart';
import '../../../core/utils/app_constants.dart';   // ✅ Important

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  void _checkVerification() {
    if (AppConstants.isAppetizeBuild) {
      // Skip liveness for Appetize.io
      setState(() => _isVerified = true);
      return;
    }
    _showLivenessVerification();
  }

  void _showLivenessVerification() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LivenessScreen(
          onSuccess: () {
            setState(() => _isVerified = true);
            Navigator.pop(context);
          },
          onFailure: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification failed. Please try again.')),
            );
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 500), _showLivenessVerification);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVerified) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return BlocProvider(
      create: (_) => DashboardBloc()..add(LoadDashboardData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
                );
                if (result == true) {
                  context.read<DashboardBloc>().add(LoadDashboardData());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                Navigator.pushNamed(context, '/export');
              },
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(LoadDashboardData());
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BalanceCard(
                        balance: state.balance,
                        income: state.totalIncome,
                        expense: state.totalExpense,
                      ),
                      const SizedBox(height: 24),
                      const Text('Expense Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SpendingChart(transactions: state.transactions),
                      const SizedBox(height: 24),
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      RecentTransactions(transactions: state.transactions.take(5).toList()),
                    ],
                  ),
                ),
              );
            }
            if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}