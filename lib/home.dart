import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:apk_catatan_keuangan/provider/transaction.dart';
import 'package:apk_catatan_keuangan/history.dart';
import 'package:apk_catatan_keuangan/statistik.dart';
import 'package:apk_catatan_keuangan/profile.dart';
import 'package:apk_catatan_keuangan/income.dart';
import 'package:apk_catatan_keuangan/outcome.dart';
import 'package:apk_catatan_keuangan/notif.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const HistoryScreen(),
    const StatisticScreen(),
    ProfilePage(onBannerVisibilityChanged: (bool) {}),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistic',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: _pages[_currentIndex],
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsProvider = Provider.of<TransactionsProvider>(context);
    final recentTransactions = transactionsProvider.recentTransactions;

    // Hitung persentase untuk pie chart
    final totalIncome = transactionsProvider.transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactionsProvider.transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final total = totalIncome + totalExpense;
    // Ensure percentages are calculated correctly, handle total == 0
    final incomePercentage = total > 0 ? (totalIncome / total * 100) : 0.0;
    final expensePercentage = total > 0 ? (totalExpense / total * 100) : 0.0;
    // Savings is what's left from 100% after income and expense
    final savingsPercentage = 100.0 - incomePercentage - expensePercentage;

    return SafeArea(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Home.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // Changed from SingleChildScrollView to Column
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - This part will remain fixed at the top
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 5),
                        Text(
                          "Welcome",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          "Nai Wanwan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Tooltip(
                      message: 'Notification',
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // My Finances Card - This part will also remain fixed
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Finances",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          CurrencyFormat.convertToIdr(
                            transactionsProvider.balance,
                            2,
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFinanceButton(
                              Icons.account_balance_wallet,
                              "Income",
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const IncomeScreen(),
                                ),
                              ),
                            ),
                            _buildFinanceButton(
                              Icons.credit_card,
                              "Outcome",
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OutcomeScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // This Expanded widget will make the remaining content scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Last Transaction Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            // Added const here
                            Text(
                              "Last Transaction",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Transaction List
                        if (recentTransactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text("No recent transactions"),
                            ),
                          )
                        else
                          ...(() {
                            List txs = List.from(recentTransactions);
                            txs.sort(
                              (a, b) => b.date.compareTo(a.date),
                            ); // Sort terbaru
                            return txs
                                .take(3)
                                .map(
                                  (tx) => _buildTransactionItem(
                                    tx.isIncome
                                        ? Icons.account_balance_wallet
                                        : Icons.credit_card,
                                    "${tx.isIncome ? '+' : '-'}Rp${NumberFormat("#,###").format(tx.amount)}",
                                    DateFormat('hh:mm a').format(tx.date),
                                    tx.isIncome ? Colors.green : Colors.red,
                                  ),
                                );
                          })().toList(),

                        const SizedBox(height: 20),

                        // Financial Condition Pie Chart
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Financial Overview",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: totalIncome,
                                              title:
                                                  '${incomePercentage.toStringAsFixed(0)}%',
                                              radius: 40,
                                              titleStyle: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            PieChartSectionData(
                                              color: Colors.red,
                                              value: totalExpense,
                                              title:
                                                  '${expensePercentage.toStringAsFixed(0)}%',
                                              radius: 40,
                                              titleStyle: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            // Handle case where total is 0 or savings is negative
                                            if (savingsPercentage > 0)
                                              PieChartSectionData(
                                                color: Colors.blue,
                                                value:
                                                    total > 0
                                                        ? (total *
                                                            savingsPercentage /
                                                            100)
                                                        : 1.0, // Give a small value if total is 0 to show the slice
                                                title:
                                                    '${savingsPercentage.toStringAsFixed(0)}%',
                                                radius: 40,
                                                titleStyle: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLegendItem(
                                          Colors.green,
                                          "Income",
                                        ),
                                        const SizedBox(height: 8),
                                        _buildLegendItem(
                                          Colors.red,
                                          "Expenses",
                                        ),
                                        const SizedBox(height: 8),
                                        _buildLegendItem(
                                          Colors.blue,
                                          "Savings",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    String amount,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
