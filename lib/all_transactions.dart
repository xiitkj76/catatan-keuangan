import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apk_catatan_keuangan/transaction_provider.dart'; // Impor TransactionProvider

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  _AllTransactionsScreenState createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _selectedPeriod = 'Day'; // Default periode
  final List<String> _periods = ['Day', 'Week', 'Month'];

  @override
  Widget build(BuildContext context) {
    // Akses TransactionProvider
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final filteredTransactions = transactionProvider.filterTransactions(
      _selectedPeriod,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown untuk memilih periode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(),
                items:
                    _periods.map((period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(
                          period,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Daftar transaksi
            Expanded(
              child:
                  filteredTransactions.isEmpty
                      ? const Center(
                        child: Text(
                          'No Transactions',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return transactionItem(
                            amount: transaction.amount,
                            time: transaction.time,
                            type: transaction.type,
                            color:
                                transaction.amount > 0
                                    ? Colors.green
                                    : Colors.red,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionItem({
    required double amount,
    required DateTime time,
    required String type,
    required Color color,
  }) {
    // Format amount ke string dengan format Rp
    final amountString =
        amount > 0
            ? '+${amount.toStringAsFixed(2)}'
            : amount.toStringAsFixed(2);
    // Format time ke string
    final timeString =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')} '
        '${time.hour < 12 ? 'AM' : 'PM'}, ${time.day} ${_intToMonth(time.month)} ${time.year}';

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
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              amount > 0 ? Icons.account_balance_wallet : Icons.credit_card,
              color: color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp$amountString',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeString,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk mengonversi angka bulan ke nama
  String _intToMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
