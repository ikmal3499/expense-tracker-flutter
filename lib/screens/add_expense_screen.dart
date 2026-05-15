import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    await context.read<ExpenseProvider>().addExpense(title, amount, _selectedDate);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Color Scheme: Red & White Minimalist
    const primaryRed = Color(0xFFE53935);
    const backgroundWhite = Colors.white;
    const textDark = Color(0xFF2D2D2D);
    const textGrey = Color(0xFF757575);
    const borderGrey = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundWhite,
      resizeToAvoidBottomInset: true, // ✅ Pastikan Scaffold respond kepada keyboard
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: backgroundWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryRed),
      ),
      // ✅ FIX: Wrap body dengan SingleChildScrollView
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          // ✅ Tambah padding bawah supaya content tak terpotong masa scroll
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // ✅ Penting: Column tak "force" full height
              children: [
                // 🏷️ Header Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Expense',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill in the details below',
                        style: TextStyle(
                          fontSize: 14,
                          color: textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // 💰 Amount Input
                _buildInputField(
                  controller: _amountController,
                  label: 'Amount',
                  hint: '0.00',
                  prefix: '\$',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter an amount';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                  isAmount: true,
                  primaryRed: primaryRed,
                  textGrey: textGrey,
                  borderGrey: borderGrey,
                ),

                const SizedBox(height: 20),

                // 📝 Title Input
                _buildInputField(
                  controller: _titleController,
                  label: 'Description',
                  hint: 'e.g. Lunch, Transport',
                  prefix: null,
                  keyboardType: TextInputType.text,
                  validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                  isAmount: false,
                  primaryRed: primaryRed,
                  textGrey: textGrey,
                  borderGrey: borderGrey,
                ),

                const SizedBox(height: 28),

                // 📅 Date Picker Button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textGrey,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _selectedDate.toString().split(' ')[0],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: textGrey,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ FIX: Ganti Spacer() dengan SizedBox fixed height
                // Spacer() cuba expand ke available space, tapi bila keyboard naik,
                // available space jadi negative → overflow!
                const SizedBox(height: 40),

                // 🔴 Save Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    child: const Text('Save Expense'),
                  ),
                ),

                // ✅ FIX: Tambah extra padding bawah untuk scroll buffer
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎨 Reusable Input Field Widget (Minimalist Style)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? prefix,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
    required bool isAmount,
    required Color primaryRed,
    required Color textGrey,
    required Color borderGrey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textGrey,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderGrey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: isAmount ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: isAmount ? 24 : 16,
              fontWeight: isAmount ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF2D2D2D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: textGrey.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
              prefixText: prefix,
              prefixStyle: TextStyle(
                color: primaryRed,
                fontSize: isAmount ? 24 : 16,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isAmount ? 20 : 18,
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                height: 1.5,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}