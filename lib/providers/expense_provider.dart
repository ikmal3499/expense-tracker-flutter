import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/expense_storage.dart';

enum ExpenseStatus { initial, loading, success, error }

class ExpenseProvider extends ChangeNotifier {
  final ExpenseStorage _storage = ExpenseStorage();
  List<Expense> _expenses = [];
  ExpenseStatus _status = ExpenseStatus.initial;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  ExpenseStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses() async {
    _status = ExpenseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _storage.loadExpenses();
      _status = ExpenseStatus.success;
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Failed to load expenses';
    }
    notifyListeners();
  }

  Future<void> addExpense(String title, double amount, DateTime date) async {
    try {
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: date,
      );
      _expenses.add(newExpense);
      await _storage.saveExpenses(_expenses);
      notifyListeners();
    } catch (_) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Failed to save expense';
      notifyListeners();
    }
  }
}