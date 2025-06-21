// import 'package:flutter/material.dart';
// import '../models/transaction.dart';

// class NotifyProvider with ChangeNotifier {
//   List<Transaction> _transactions = [];
//   double _balance = 50000; // Saldo awal

//   List<Transaction> get transactions => _transactions;
//   double get balance => _balance;

//   void addTransaction(Transaction newTransaction) {
//     _transactions.add(newTransaction);

//     // Update balance
//     if (newTransaction.isIncome) {
//       _balance += newTransaction.amount;
//     } else {
//       _balance -= newTransaction.amount;
//     }

//     notifyListeners();
//   }

//   void clearTransactions() {
//     _transactions.clear();
//     notifyListeners();
//   }

//   void removeTransactionById(String id) {
//     _transactions.removeWhere((tx) => tx.id == id);
//     notifyListeners();
//   }

//   void removeTransactionsByIds(List<String> ids) {
//     _transactions.removeWhere((tx) => ids.contains(tx.id));
//     notifyListeners();
//   }

//   List<Transaction> get recentTransactions {
//     return _transactions.where((tx) {
//       return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
//     }).toList();
//   }
// }
