import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/expense_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..loadExpenses(),
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const ExpenseListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}