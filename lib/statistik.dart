import 'package:apk_catatan_keuangan/home.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';
import 'package:intl/intl.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  String? selectedMonth;
  List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'October',
    'November',
    'Desember',
  ];

  String formatRupiah(double number, {bool simplify = false}) {
    if (simplify) {
      if (number >= 1000000) {
        double valueInJuta = number / 1000000;
        return 'Rp${valueInJuta.toStringAsFixed(valueInJuta.truncateToDouble() == valueInJuta ? 0 : 1)}jt';
      } else if (number >= 1000) {
        double valueInRibu = number / 1000;
        return 'Rp${valueInRibu.toStringAsFixed(valueInRibu.truncateToDouble() == valueInRibu ? 0 : 1)}rb';
      }
    }
    return 'Rp${NumberFormat("#,###").format(number)}';
  }

  List<BarChartGroupData> generateChartData(List<dynamic> transactions) {
    List<double> incomeByDay = List.filled(7, 0);
    List<double> expenseByDay = List.filled(7, 0);

    for (var tx in transactions) {
      DateTime date;
      if (tx.date is DateTime) {
        date = tx.date;
      } else if (tx['date'] is String) {
        date = DateTime.parse(tx['date']);
      } else {
        date = DateTime.now();
      }

      int dayIndex = date.weekday - 1;
      if (tx.isIncome == true || (tx is Map && tx['isIncome'] == true)) {
        incomeByDay[dayIndex] += tx.amount ?? tx['amount'] ?? 0;
      } else {
        expenseByDay[dayIndex] += tx.amount ?? tx['amount'] ?? 0;
      }
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: incomeByDay[index],
            color: Colors.green,
            width: 12,
          ),
          BarChartRodData(
            toY: expenseByDay[index],
            color: Colors.red,
            width: 12,
          ),
        ],
      );
    });
  }

  List<dynamic> filterTransactionsByMonth(
    List<dynamic> allTransactions,
    int? month,
  ) {
    if (month == null) return allTransactions;

    return allTransactions.where((tx) {
      DateTime date;
      if (tx.date is DateTime) {
        date = tx.date;
      } else if (tx['date'] is String) {
        date = DateTime.parse(tx['date']);
      } else {
        date = DateTime.now();
      }
      return date.month == month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = Provider.of<TransactionsProvider>(context);
    final balance = transactionsProvider.balance;
    final allTransactions = transactionsProvider.transactions;
    int? selectedMonthIndex =
        selectedMonth != null ? months.indexOf(selectedMonth!) + 1 : null;

    final filteredTransactions = filterTransactionsByMonth(
      allTransactions,
      selectedMonthIndex,
    );

    final chartData = generateChartData(filteredTransactions);

    double maxY = 10000000;
    if (chartData.isNotEmpty) {
      double maxIncome = chartData
          .map((e) => e.barRods[0].toY)
          .reduce((a, b) => a > b ? a : b);
      double maxExpense = chartData
          .map((e) => e.barRods[1].toY)
          .reduce((a, b) => a > b ? a : b);
      maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
      if (maxY < 1000000) maxY = 1000000;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Text(
                "Statistik",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              const Text(
                "Total Saldo",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                CurrencyFormat.convertToIdr(balance, 2),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
                      onChanged: (String? value) {
                        setState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxY / 5,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Text(
                                  formatRupiah(value, simplify: true),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              List<String> days = [
                                "Sen",
                                "Sel",
                                "Rab",
                                "Kam",
                                "Jum",
                                "Sab",
                                "Min",
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData,
                      alignment: BarChartAlignment.spaceBetween,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              formatRupiah(rod.toY),
                              TextStyle(
                                color: rod.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  legendItem(Colors.green, "Pemasukan"),
                  const SizedBox(width: 20),
                  legendItem(Colors.red, "Pengeluaran"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}
