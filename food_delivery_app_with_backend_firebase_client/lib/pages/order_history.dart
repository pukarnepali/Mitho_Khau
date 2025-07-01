import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        orders = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'orderId': doc.id,
            'orderTime': data['orderTime'] ?? Timestamp.now(),
            'orderItems': data['items'] ?? [],
            'totalPrice': data['totalAmount'] ?? 0.0,
            'status': data['status'] ?? 'Processing',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching orders: $e';
        isLoading = false;
      });
    }
  }

  Future<bool> _showConfirmDialog(
      BuildContext context, String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
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

  Widget _buildOrderTile(
      Map<String, dynamic> order, String formattedOrderTime) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${order['orderId']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          Text(
            'Date: $formattedOrderTime',
            style: TextStyle(
              fontSize: 14,
              color: Colors.brown.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children:
                (order['orderItems'] as List<dynamic>).map<Widget>((item) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Status: ${order['status']}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(order['status']),
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.brown.shade200),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA000),
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 1),
                blurRadius: 4,
              )
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Colors.deepOrangeAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDEB71),
              Color(0xFFF8D800),
              Color(0xFFFFC107),
              Color(0xFFFFA000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : orders.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderTime =
                              (order['orderTime'] as Timestamp).toDate();
                          final formattedOrderTime =
                              DateFormat('yyyy-MM-dd – hh:mm a')
                                  .format(orderTime);

                          return Dismissible(
                            key: Key(order['orderId']),
                            background: Container(
                              color: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Delete Order",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.settings, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Update Status",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe right to delete order
                                bool confirm = await _showConfirmDialog(
                                  context,
                                  "Delete Order",
                                  "Are you sure you want to delete this order?",
                                );
                                if (confirm) {
                                  await _firestore
                                      .collection('orders')
                                      .doc(order['orderId'])
                                      .delete();
                                  setState(() => orders.removeAt(index));
                                  return true;
                                }
                                return false;
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                // Swipe left to change status
                                bool? statusChanged = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Change Order Status"),
                                    content: const Text(
                                        "Do you want to cancel or mark the order as received?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await _firestore
                                              .collection('orders')
                                              .doc(order['orderId'])
                                              .update({'status': 'Canceled'});
                                          // Update status in local state
                                          setState(() {
                                            orders[index]['status'] =
                                                'Canceled';
                                          });
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Cancel Order"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await _firestore
                                              .collection('orders')
                                              .doc(order['orderId'])
                                              .update({'status': 'Received'});
                                          // Update status in local state
                                          setState(() {
                                            orders[index]['status'] =
                                                'Received';
                                          });
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Mark as Received"),
                                      ),
                                    ],
                                  ),
                                );
                                return statusChanged ?? false;
                              }
                              return false;
                            },
                            child: _buildOrderTile(order, formattedOrderTime),
                          );
                        },
                      ),
      ),
    );
  }
}
