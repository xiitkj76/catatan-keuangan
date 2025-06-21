import 'package:apk_catatan_keuangan/models/transaction.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Set<String> _selectedIds = {}; // Store selected transaction IDs
  bool _selectAll = false;
  List<Transaction> _visibleTransactions = [];

  @override
  void initState() {
    super.initState();
    final transactionsProvider = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );
    final filteredTransactions =
        transactionsProvider.recentTransactions.where((tx) {
          return tx.isDeleted == false;
        }).toList();
    _visibleTransactions = List.from(filteredTransactions);
  }

  void _removeVisibleById(String id) {
    final transactionsProvider = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );
    setState(() {
      transactionsProvider.softDeleteTransactionById(id);
      _visibleTransactions.removeWhere((tx) => tx.id == id);
      _selectedIds.remove(id);
    });
  }

  void _removeSelectedVisible() {
    final transactionsProvider = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );
    setState(() {
      transactionsProvider.softDeleteTransactionsByIds(_selectedIds.toList());
      _visibleTransactions.removeWhere((tx) => _selectedIds.contains(tx.id));
      _selectedIds.clear();
      _selectAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_visibleTransactions.isNotEmpty)
            IconButton(
              tooltip: 'Select all',
              icon: Icon(
                _selectAll ? Icons.check_box : Icons.check_box_outline_blank,
                color: _selectAll ? const Color.fromARGB(255, 114, 65, 205) : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _selectAll = !_selectAll;
                  _selectedIds.clear();
                  if (_selectAll) {
                    _selectedIds.addAll(
                      _visibleTransactions.map((tx) => tx.id),
                    );
                  }
                });
              },
            ),
          if (_selectedIds.isNotEmpty)
            Tooltip(
              message: 'Delete',
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _removeSelectedVisible,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _visibleTransactions.isEmpty
                ? const Center(
                  child: Text(
                    'No Notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  itemCount: _visibleTransactions.length,
                  itemBuilder: (context, index) {
                    final notification = _visibleTransactions[index];
                    final isSelected = _selectedIds.contains(notification.id);
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(notification.id);
                          } else {
                            _selectedIds.add(notification.id);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          notificationItem(
                            title:
                                "${notification.isIncome ? 'Pemasukan Baru' : 'Pengeluaran'}",
                            amount:
                                "${notification.isIncome ? '+' : '-'}Rp${NumberFormat("#,###", "id_ID").format(notification.amount)}",
                            time: DateFormat(
                              'dd MMM yyyy - HH:mm',
                            ).format(notification.date),
                            color:
                                notification.isIncome
                                    ? Colors.green
                                    : Colors.red,
                            onDelete: () => _removeVisibleById(notification.id),
                            showCheckbox: _selectedIds.isNotEmpty,
                            isChecked: isSelected,
                            onCheckboxChanged: (checked) {
                              setState(() {
                                if (checked) {
                                  _selectedIds.add(notification.id);
                                } else {
                                  _selectedIds.remove(notification.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget notificationItem({
    required String title,
    required String amount,
    required String time,
    required Color color,
    required VoidCallback onDelete,
    required bool showCheckbox,
    required bool isChecked,
    required Function(bool) onCheckboxChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          if (showCheckbox)
            Checkbox(
              value: isChecked,
              onChanged: (value) => onCheckboxChanged(value!),
            ),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              amount.startsWith('+')
                  ? Icons.account_balance_wallet
                  : Icons.credit_card,
              color: color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Delete',
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
