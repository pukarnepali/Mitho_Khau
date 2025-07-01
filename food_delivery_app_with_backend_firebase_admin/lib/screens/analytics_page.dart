import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> revenueByDate = {};
  Map<String, int> itemSales = {};
  Map<String, double> itemRevenue = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      Map<String, double> tempRevenueByDate = {};
      Map<String, int> tempItemSales = {};
      Map<String, double> tempItemRevenue = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderTime = (data['orderTime'] as Timestamp).toDate();
        final dateKey = "${orderTime.year}-${orderTime.month}-${orderTime.day}";
        final totalAmount = (data['totalAmount'] ?? 0).toDouble();
        tempRevenueByDate[dateKey] =
            (tempRevenueByDate[dateKey] ?? 0) + totalAmount;

        List<dynamic> items = data['items'] ?? [];
        for (var item in items) {
          String itemName = item['itemName'];
          int quantity = (item['quantity'] ?? 0).toInt();
          double price = (item['itemPrice'] ?? 0).toDouble();
          double earnings = quantity * price;

          tempItemSales[itemName] = (tempItemSales[itemName] ?? 0) + quantity;
          tempItemRevenue[itemName] =
              (tempItemRevenue[itemName] ?? 0) + earnings;
        }
      }

      setState(() {
        revenueByDate = tempRevenueByDate;
        itemSales = tempItemSales;
        itemRevenue = tempItemRevenue;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<MapEntry<String, int>> getTopItems() {
    final entries = itemSales.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).toList();
  }

  Map<String, double> getWeeklyRevenue() {
    Map<String, double> weeklyRevenue = {};
    for (var entry in revenueByDate.entries) {
      final parts = entry.key.split("-");
      DateTime date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final week = DateFormat('y-ww').format(date); // e.g., 2024-15
      weeklyRevenue[week] = (weeklyRevenue[week] ?? 0) + entry.value;
    }
    return weeklyRevenue;
  }

  List<BarChartGroupData> getDailyChartData() {
    List<String> sortedDates = revenueByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    return sortedDates.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;
      double revenue = revenueByDate[date]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: revenue, color: Colors.blue, width: 16),
        ],
      );
    }).toList();
  }

  List<String> getChartLabels() {
    List<String> sortedDates = revenueByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    return sortedDates.map((d) {
      final parts = d.split("-");
      return "${parts[1]}/${parts[2]}";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yMMMd');
    final topItems = getTopItems();
    final weeklyRevenue = getWeeklyRevenue();
    final chartLabels = getChartLabels();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top 3 Most Sold Items',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...topItems.map((entry) {
                      final itemName = entry.key;
                      final qty = entry.value;
                      final earnings =
                          itemRevenue[itemName]!.toStringAsFixed(2);
                      return ListTile(
                        title: Text('$itemName x$qty'),
                        trailing: Text('NPR $earnings',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Text('Daily Revenue Chart',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: DailyRevenueChart()),
                    const SizedBox(height: 20),
                    const Text('Weekly Revenue Summary',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ...weeklyRevenue.entries.map((entry) {
                      return ListTile(
                        title: Text("Week ${entry.key}"),
                        trailing: Text('NPR ${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold)),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  Widget DailyRevenueChart() {
    final chartData = getDailyChartData();
    final labels = getChartLabels();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          )),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(labels[index],
                      style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData,
      ),
    );
  }
}
