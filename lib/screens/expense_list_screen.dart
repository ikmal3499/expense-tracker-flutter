import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import '../widgets/empty_state_widget.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Color Scheme: Red & White Minimalist (Consistent with AddExpenseScreen)
    const primaryRed = Color(0xFFE53935);
    const backgroundWhite = Colors.white;
    const textDark = Color(0xFF2D2D2D);
    const textGrey = Color(0xFF757575);
    const cardBackground = Color(0xFFFAFAFA);
    const borderGrey = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'My Expenses',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: backgroundWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryRed),
        actions: [
          // Optional: Quick summary chip
          Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              final total = provider.expenses.fold<double>(
                0,
                (sum, item) => sum + item.amount,
              );
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: primaryRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            // 🔄 Loading State
            if (provider.status == ExpenseStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: primaryRed,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your expenses...',
                      style: TextStyle(color: textGrey, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // ❌ Error State
            if (provider.status == ExpenseStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: primaryRed,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        provider.errorMessage ?? 'Something went wrong',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again',
                        style: TextStyle(color: textGrey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => provider.loadExpenses(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // ✅ BETUL
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ Success / Initial State
            if (provider.expenses.isEmpty) {
              // Reuse your EmptyStateWidget but with themed icon
              return EmptyStateWidget(message: 'No expenses yet.\nTap + to add your first one!');
            }

            // 📋 Expense List
            return Column(
              children: [
                // Optional: Subtle divider under app bar area
                Container(
                  height: 1,
                  color: borderGrey.withOpacity(0.5),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: provider.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = provider.expenses[index];
                      return _ExpenseCard(
                        expense: expense,
                        primaryRed: primaryRed,
                        textDark: textDark,
                        textGrey: textGrey,
                        cardBackground: cardBackground,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

// 🎨 Reusable Expense Card Widget (Minimalist Design)
class _ExpenseCard extends StatelessWidget {
  final dynamic expense; // Replace with your actual Expense type
  final Color primaryRed;
  final Color textDark;
  final Color textGrey;
  final Color cardBackground;

  const _ExpenseCard({
    required this.expense,
    required this.primaryRed,
    required this.textDark,
    required this.textGrey,
    required this.cardBackground,
  });

  @override
  Widget build(BuildContext context) {
    // Format date nicely: "14 May" instead of "2024-05-14 00:00:00"
    final formattedDate = _formatDate(expense.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Optional: Navigate to detail screen later
            // Navigator.push(context, ...);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 🔴 Left accent bar
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),

                // 📅 Date Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: primaryRed.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 📝 Title & Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: primaryRed,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Format DateTime to "14 May" or "Today"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}