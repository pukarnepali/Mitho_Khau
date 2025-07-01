import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserDetailsPage({super.key, required this.user});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> userOrders = [];
  double totalSpent = 0.0;
  Map<String, int> itemCount = {};

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: widget.user['userId'])
          .get();

      double tempTotal = 0.0;
      Map<String, int> tempItemCount = {}; // ✅ correct initialization
      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        tempTotal += (data['totalAmount'] ?? 0.0);

        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final name = item['itemName'];
          final qty = (item['quantity'] ?? 0).toInt(); // ✅ fix here

          tempItemCount[name] = ((tempItemCount[name] ?? 0) + qty).toInt();
        }

        orders.add({
          'orderId': doc.id,
          'orderTime': data['orderTime']?.toDate(),
          'totalAmount': data['totalAmount'],
          'items': items,
        });
      }

      setState(() {
        totalSpent = tempTotal;
        itemCount = tempItemCount;
        userOrders = orders;
      });
    } catch (e) {
      print('Error fetching user orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mostOrdered = itemCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user['username']} Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: userOrders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Text('Email: ${widget.user['email']}'),
                  Text('Phone: ${widget.user['phone']}'),
                  Text('Address: ${widget.user['address']}'),
                  const SizedBox(height: 16),
                  Text('Total Spent: \Npr $totalSpent',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Most Ordered Items:',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...mostOrdered.take(3).map((e) => Text(
                      '${e.key} x${e.value}')), // showing top 3 most ordered
                  const Divider(height: 32),
                  Text('All Orders:',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...userOrders.map((order) => Card(
                        child: ListTile(
                          title: Text('Order ID: ${order['orderId']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Date: ${order['orderTime'].toString().split(".")[0]}'),
                              Text('Total: \Npr ${order['totalAmount']}'),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
