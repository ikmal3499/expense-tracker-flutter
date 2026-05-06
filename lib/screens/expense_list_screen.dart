import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../widgets/empty_state_widget.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case ExpenseStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ExpenseStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage ?? 'Unknown error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadExpenses(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ExpenseStatus.initial:
            case ExpenseStatus.success:
              if (provider.expenses.isEmpty) {
                return const EmptyStateWidget(message: 'No expenses yet. Tap + to add one.');
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.expenses.length,
                itemBuilder: (context, index) {
                  final expense = provider.expenses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(expense.title),
                      subtitle: Text(expense.date.toString().split(' ')[0]),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}