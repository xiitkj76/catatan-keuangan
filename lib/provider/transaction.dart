import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionsProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  double _balance = 50000; // Saldo awal

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;

  void addTransaction(Transaction newTransaction) {
    _transactions.add(newTransaction);

    // Update balance
    if (newTransaction.isIncome) {
      _balance += newTransaction.amount;
    } else {
      _balance -= newTransaction.amount;
    }

    notifyListeners();
  }

  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  List<Transaction> get recentTransactions {
    return _transactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void softDeleteTransactionById(String id) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(isDeleted: true);
      notifyListeners();
    }
  }

  void softDeleteTransactionsByIds(List<String> ids) {
    for (var i = 0; i < _transactions.length; i++) {
      if (ids.contains(_transactions[i].id)) {
        _transactions[i] = _transactions[i].copyWith(isDeleted: true);
      }
    }
    notifyListeners();
  }
}