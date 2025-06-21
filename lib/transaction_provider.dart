import 'package:flutter/material.dart';

class Transaction {
  final double amount;
  final DateTime time;
  final String type;

  Transaction({required this.amount, required this.time, required this.type});
}

class TransactionProvider with ChangeNotifier {
  // Daftar transaksi
  List<Transaction> _transactions = [
    Transaction(
      amount: 200000,
      time: DateTime(2025, 4, 28, 11, 0), // Hari ini
      type: 'Income',
    ),
    Transaction(
      amount: -100000,
      time: DateTime(2025, 4, 28, 11, 0), // Hari ini
      type: 'Expense',
    ),
    Transaction(
      amount: 500000,
      time: DateTime(2025, 4, 27, 9, 0), // Kemarin
      type: 'Income',
    ),
    Transaction(
      amount: -50000,
      time: DateTime(2025, 4, 25, 8, 0), // Minggu ini
      type: 'Expense',
    ),
    Transaction(
      amount: 1000000,
      time: DateTime(2025, 4, 15, 10, 0), // Bulan ini
      type: 'Income',
    ),
    Transaction(
      amount: -200000,
      time: DateTime(2025, 4, 10, 15, 0), // Bulan ini
      type: 'Expense',
    ),
  ];

  // Getter untuk transaksi
  List<Transaction> get transactions => _transactions;

  // Fungsi untuk menambah transaksi baru
  void addTransaction(double amount, DateTime time, String type) {
    _transactions.add(Transaction(amount: amount, time: time, type: type));
    notifyListeners(); // Beritahu widget yang mendengarkan
  }

  // Fungsi untuk memfilter transaksi berdasarkan periode
  List<Transaction> filterTransactions(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _transactions.where((transaction) {
      if (period == 'Day') {
        return transaction.time.year == today.year &&
            transaction.time.month == today.month &&
            transaction.time.day == today.day;
      } else if (period == 'Week') {
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return transaction.time.isAfter(
              weekStart.subtract(const Duration(days: 1)),
            ) &&
            transaction.time.isBefore(weekEnd.add(const Duration(days: 1)));
      } else {
        // Month
        return transaction.time.month == today.month &&
            transaction.time.year == today.year;
      }
    }).toList();
  }
}
