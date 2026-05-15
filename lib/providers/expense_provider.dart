import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Optional: untuk cloud sync
import '../models/expense.dart';
import '../services/expense_storage.dart';

enum ExpenseStatus { initial, loading, success, error }

class ExpenseProvider extends ChangeNotifier {
  // 🔥 Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Optional
  
  // 🗄️ Local storage (primary - offline first)
  final ExpenseStorage _storage = ExpenseStorage();
  
  // 📦 State
  List<Expense> _expenses = [];
  ExpenseStatus _status = ExpenseStatus.initial;
  String? _errorMessage;
  
  // ⚙️ Config: Set true kalau nak sync ke Firestore (cloud)
  static const bool _enableCloudSync = false; // ✅ Default: local only (safe for junior submission)

  // 📬 Getters
  List<Expense> get expenses => _expenses;
  ExpenseStatus get status => _status;
  String? get errorMessage => _errorMessage;
  
  // 🔐 Auth getters
  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // 🔄 Load expenses (local first, optional cloud sync)
  Future<void> loadExpenses() async {
    _status = ExpenseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Load dari local storage dulu (fast & offline)
      _expenses = await _storage.loadExpenses();
      
      // 2️⃣ Optional: Sync dari cloud kalau user login & cloud sync enabled
      if (_enableCloudSync && isAuthenticated) {
        await _syncFromCloud();
      }
      
      _status = ExpenseStatus.success;
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Failed to load expenses: ${e.toString()}';
      if (kDebugMode) print('❌ Load error: $e');
    }
    notifyListeners();
  }

  // ➕ Add expense (save local + optional cloud)
  Future<void> addExpense(String title, double amount, DateTime date) async {
    try {
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: date,
      );
      
      // 1️⃣ Simpan local dulu (wajib)
      _expenses.add(newExpense);
      await _storage.saveExpenses(_expenses);
      
      // 2️⃣ Optional: Sync ke cloud kalau enabled
      if (_enableCloudSync && isAuthenticated) {
        await _syncToCloud(newExpense);
      }
      
      notifyListeners();
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Failed to save expense';
      if (kDebugMode) print('❌ Save error: $e');
      notifyListeners();
      rethrow; // Optional: biar caller tahu ada error
    }
  }

  // 🗑️ Delete expense (optional feature)
  Future<void> deleteExpense(String expenseId) async {
    try {
      _expenses.removeWhere((e) => e.id == expenseId);
      await _storage.saveExpenses(_expenses);
      
      if (_enableCloudSync && isAuthenticated) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(expenseId)
            .delete();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Delete error: $e');
    }
  }

  // 🔐 Login function (wrapper untuk Firebase Auth)
  Future<void> login(String email, String password) async {
    _status = ExpenseStatus.loading;
    notifyListeners();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _status = ExpenseStatus.success;
      await loadExpenses(); // Reload expenses selepas login
    } on FirebaseAuthException catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = _getAuthErrorMessage(e.code);
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Login failed: ${e.toString()}';
    }
    notifyListeners();
  }

  // 🔐 Register function
  Future<void> register(String email, String password) async {
    _status = ExpenseStatus.loading;
    notifyListeners();
    
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _status = ExpenseStatus.success;
      // New user: expenses list kosong, tak perlu load
    } on FirebaseAuthException catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = _getAuthErrorMessage(e.code);
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Registration failed: ${e.toString()}';
    }
    notifyListeners();
  }

  // 🔐 Logout function
  Future<void> logout() async {
    await _auth.signOut();
    // Optional: Clear local data kalau nak strict per-user
    // _expenses = [];
    // await _storage.saveExpenses([]);
    notifyListeners();
  }

  // ☁️ Sync to Firestore (optional - only if _enableCloudSync = true)
  Future<void> _syncToCloud(Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toJson());
    } catch (e) {
      if (kDebugMode) print('⚠️ Cloud sync failed: $e');
      // Jangan throw - local save dah berjaya, cloud just bonus
    }
  }

  // ☁️ Sync from Firestore (optional)
  Future<void> _syncFromCloud() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();
          
      final cloudExpenses = snapshot.docs
          .map((doc) => Expense.fromJson(doc.data()))
          .toList();
          
      // Merge: cloud data as source of truth (optional logic)
      if (cloudExpenses.isNotEmpty) {
        _expenses = cloudExpenses;
        await _storage.saveExpenses(_expenses); // Update local dengan cloud data
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Cloud fetch failed: $e');
      // Fallback to local data - tak throw error
    }
  }

  // 🎯 Helper: Map Firebase auth error codes to user-friendly messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}