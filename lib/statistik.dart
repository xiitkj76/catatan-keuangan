import 'package:apk_catatan_keuangan/home.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  String? selectedMonth;
  int? selectedYear;
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

  List<int> getYears() {
    int currentYear = DateTime.now().year;
    // Menghasilkan tahun saat ini dan 5 tahun ke belakang
    return List<int>.generate(6, (index) => currentYear - index);
  }

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
      double amount;
      bool isIncome;

      if (tx is Map) {
        date = DateTime.parse(tx['date'].toString());
        amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        isIncome = (tx['isIncome'] as bool?) ?? false;
      } else {
        date = tx.date as DateTime;
        amount = (tx.amount as num?)?.toDouble() ?? 0.0;
        isIncome = (tx.isIncome as bool?) ?? false;
      }

      int dayIndex = date.weekday - 1;
      if (isIncome) {
        incomeByDay[dayIndex] += amount;
      } else {
        expenseByDay[dayIndex] += amount;
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

  List<dynamic> filterTransactionsByMonthAndYear(
    List<dynamic> allTransactions,
    int? month,
    int? year,
  ) {
    return allTransactions.where((tx) {
      DateTime date;
      if (tx is Map && tx.containsKey('date')) {
        date = DateTime.parse(tx['date'].toString());
      } else if (tx.date is DateTime) {
        date = tx.date;
      } else {
        date = DateTime.now();
      }

      bool matchesMonth = (month == null || date.month == month);
      bool matchesYear = (year == null || date.year == year);

      return matchesMonth && matchesYear;
    }).toList();
  }

  Future<void> _generatePdf(
    List<dynamic> transactions,
    double balance,
    String periodDisplay,
  ) async {
    // renamed period to periodDisplay
    final pdf = pw.Document();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in transactions) {
      double amount = 0;
      bool isIncome = false;

      if (tx is Map) {
        amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        isIncome = (tx['isIncome'] as bool?) ?? false;
      } else {
        amount = (tx.amount as num?)?.toDouble() ?? 0.0;
        isIncome = (tx.isIncome as bool?) ?? false;
      }

      if (isIncome) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Statistik Keuangan',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Periode: $periodDisplay', // Menggunakan periodDisplay yang lebih deskriptif
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Ringkasan Saldo:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Total Saldo: ${CurrencyFormat.convertToIdr(balance, 2)}',
              ),
              pw.Text('Total Pemasukan: ${formatRupiah(totalIncome)}'),
              pw.Text('Total Pengeluaran: ${formatRupiah(totalExpense)}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Daftar Transaksi:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Tanggal', 'Deskripsi', 'Jumlah', 'Tipe'],
                data:
                    transactions.map((tx) {
                      DateTime date;
                      String title;
                      double amount;
                      bool isIncome;

                      if (tx is Map) {
                        date = DateTime.parse(tx['date'].toString());
                        title = tx['title']?.toString() ?? 'N/A';
                        amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                        isIncome = (tx['isIncome'] as bool?) ?? false;
                      } else {
                        date = tx.date as DateTime;
                        title = tx.title?.toString() ?? 'N/A';
                        amount = (tx.amount as num?)?.toDouble() ?? 0.0;
                        isIncome = (tx.isIncome as bool?) ?? false;
                      }

                      String formattedDate = DateFormat(
                        'dd MMM yyyy',
                      ).format(date);
                      String type = isIncome ? 'Pemasukan' : 'Pengeluaran';

                      return [formattedDate, title, formatRupiah(amount), type];
                    }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.black),
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ],
          );
        },
      ),
    );

    // Gunakan periodString untuk nama file, karena itu sudah cukup deskriptif
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'laporan_statistik_${periodDisplay.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = Provider.of<TransactionsProvider>(context);
    final balance = transactionsProvider.balance;
    final allTransactions = transactionsProvider.transactions;
    int? selectedMonthIndex =
        selectedMonth != null ? months.indexOf(selectedMonth!) + 1 : null;

    final filteredTransactions = filterTransactionsByMonthAndYear(
      allTransactions,
      selectedMonthIndex,
      selectedYear,
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

    // NEW: Logic for periodDisplayString that goes into the PDF content
    String periodDisplayString;
    if (selectedMonth != null && selectedYear != null) {
      periodDisplayString = 'Bulan: $selectedMonth, Tahun: $selectedYear';
    } else if (selectedMonth != null) {
      periodDisplayString = 'Bulan: $selectedMonth (Semua Tahun)';
    } else if (selectedYear != null) {
      periodDisplayString = 'Tahun: $selectedYear (Semua Bulan)';
    } else {
      periodDisplayString = 'Semua Waktu';
    }

    // The filename string can be simpler, or use periodDisplayString with replacements
    String filenamePeriodString;
    if (selectedMonth != null && selectedYear != null) {
      filenamePeriodString = '${selectedMonth}_$selectedYear';
    } else if (selectedMonth != null) {
      filenamePeriodString = selectedMonth!;
    } else if (selectedYear != null) {
      filenamePeriodString = selectedYear.toString();
    } else {
      filenamePeriodString = 'Semua_Waktu';
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
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      hint: const Text('Pilih Tahun'),
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Semua Tahun'),
                        ),
                        ...getYears().map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          selectedYear = value;
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Meneruskan periodDisplayString dan filenamePeriodString
                    _generatePdf(
                      filteredTransactions,
                      balance,
                      periodDisplayString,
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Laporan PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
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
