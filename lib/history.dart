import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';
import 'package:apk_catatan_keuangan/models/transaction.dart'
    as my_transaction; // untuk menghindari konflik nama

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedMonth = 'Semua Bulan';
  final List<String> months = [
    'Semua Bulan',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = Provider.of<TransactionsProvider>(context);
    final List<my_transaction.Transaction> allTransactions =
        transactionsProvider.transactions.where((t) => t.date != null).toList();

    List<my_transaction.Transaction> filteredTransactions;
    if (selectedMonth == 'Semua Bulan') {
      filteredTransactions = List.from(allTransactions);
    } else {
      final monthIndex = months.indexOf(selectedMonth) - 1;
      filteredTransactions =
          allTransactions.where((tx) {
            return tx.date!.month - 1 == monthIndex;
          }).toList();
    }

    filteredTransactions.sort((a, b) => b.date!.compareTo(a.date!));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        hint: const Text('Pilih Bulan'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Semua Bulan'),
                          ),
                          ...months.map((month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedMonth = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),
            if (filteredTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Tidak ada transaksi")),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (ctx, index) {
                    final tx = filteredTransactions[index];
                    return _buildTransactionItem(
                      tx.isIncome
                          ? Icons.account_balance_wallet
                          : Icons.credit_card,
                      "${tx.isIncome ? '+' : '-'}Rp${NumberFormat("#,###", "id_ID").format(tx.amount)}",
                      tx.title,
                      DateFormat(
                        'dd MMM yyyy - HH:mm',
                        'id_ID',
                      ).format(tx.date!),
                      tx.isIncome ? Colors.green : Colors.red,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    String amount,
    String title,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(15),
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
            child: Icon(icon, color: color),
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
                Text(amount, style: TextStyle(fontSize: 16, color: color)),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
