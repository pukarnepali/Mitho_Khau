import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/order_detail.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allOrders = [];

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('orderTime', descending: true)
          .get();

      List<Map<String, dynamic>> tempOrders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'];

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final customerName = userDoc.data()?['username'] ?? 'Unknown';

        tempOrders.add({
          'orderId': doc.id,
          'customer': customerName,
          'address': data['userAddress'],
          'orderTime': data['orderTime'] != null
              ? (data['orderTime'] as Timestamp).toDate()
              : null,
          'orderItems': data['items'] ?? [],
          'totalPrice': data['totalAmount'] ?? 0.0,
          'status': data['status'] ?? 'Pending',
        });
      }

      setState(() {
        allOrders = tempOrders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _changeOrderStatus(String orderId, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        String selectedStatus = currentStatus;
        return AlertDialog(
          title: const Text('Change Order Status'),
          content: DropdownButton<String>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: 'Pending', child: Text('Pending')),
              DropdownMenuItem(value: 'Delivering', child: Text('Delivering')),
              DropdownMenuItem(value: 'Received', child: Text('Received')),
              DropdownMenuItem(value: 'Canceled', child: Text('Canceled')),
            ],
            onChanged: (value) {
              selectedStatus = value!;
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );

    if (newStatus != null && newStatus != currentStatus) {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      fetchAllOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.green;
      case 'Delivering':
        return Colors.orange;
      case 'Canceled':
        return Colors.black;
      case 'Pending':
      default:
        return Colors.red;
    }
  }

  Widget _buildOrderListByStatus(String status) {
    final filteredOrders =
        allOrders.where((order) => order['status'] == status).toList();

    if (filteredOrders.isEmpty) {
      return Center(child: Text('No $status orders'));
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Dismissible(
          key: Key(order['orderId']),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            await _changeOrderStatus(order['orderId'], order['status']);
            return false;
          },
          background: Container(
            color: Colors.blue,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.sync, color: Colors.white, size: 32),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPage(order: order),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order['orderId']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Customer: ${order['customer']}'),
                      Text('Address: ${order['address']}'),
                      Text('Date: ${order['orderTime']}'),
                      const SizedBox(height: 10),
                      Column(
                        children:
                            (order['orderItems'] as List).map<Widget>((item) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['itemName']} x${item['quantity']}'),
                              Text('Npr ${item['itemPrice']}'),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total: Npr ${order['totalPrice']}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Status: ${order['status']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order['status']),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Orders'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Delivering'),
              Tab(text: 'Received'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: allOrders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOrderListByStatus('Pending'),
                  _buildOrderListByStatus('Delivering'),
                  _buildOrderListByStatus('Received'),
                  _buildOrderListByStatus('Canceled'),
                ],
              ),
      ),
    );
  }
}
