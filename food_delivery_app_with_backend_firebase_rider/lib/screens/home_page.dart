import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'order_detail_page.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allOrders = [];
  String selectedFilter = 'On Delivery';

  @override
  void initState() {
    super.initState();
    fetchRiderOrders();
  }

  Future<void> fetchRiderOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('status', whereIn: ['Delivering', 'Received'])
          .orderBy('orderTime', descending: true)
          .get();

      List<Map<String, dynamic>> tempOrders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // final userEmail = data['userEmail'];

        // final userDoc =
        //     await _firestore.collection('users').doc(userEmail).get();
        // // final customerData = userDoc.data() ?? {};
        // // final customerName = data['username'] ?? 'Unknown';
        // // final phone = data['phone'] ?? 'N/A';

        tempOrders.add({
          'orderId': doc.id,
          'customer': data['userName'] ?? 'Guest',
          'phone': data['phone'] ?? '9811111111',
          'address': data['userAddress'],
          'orderTime': data['orderTime']?.toDate(),
          'orderItems': data['items'],
          'totalPrice': data['totalAmount'],
          'status': data['status'],
        });
      }

      setState(() {
        allOrders = tempOrders;
      });
    } catch (e) {
      print('Error fetching rider orders: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    if (selectedFilter == 'Delivered') {
      return allOrders.where((order) => order['status'] == 'Received').toList();
    } else if (selectedFilter == 'On Delivery') {
      return allOrders
          .where((order) => order['status'] == 'Delivering')
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          )
        ],
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.blue),
      //         child: Column(
      //           children: [
      //             Image(
      //               height: 100,
      //               image: AssetImage('images/mithokhau-logo-light.png'),
      //             ),
      //             Text("Mitho Khau Rider Panel"),
      //           ],
      //         ),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.dashboard),
      //         title: const Text('Orders'),
      //         onTap: () => Navigator.pop(context),
      //       ),
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ToggleButtons(
            isSelected: [
              selectedFilter == 'On Delivery',
              selectedFilter == 'Delivered',
            ],
            onPressed: (int index) {
              setState(() {
                selectedFilter = index == 0 ? 'On Delivery' : 'Delivered';
              });
            },
            color: Colors.black,
            selectedColor: Colors.white,
            fillColor: Colors.blue,
            borderRadius: BorderRadius.circular(10),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('On Delivery'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Delivered'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(order['customer']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text('Phone: ${order['phone']}'),
                              Text('Address: ${order['address']}'),
                              Text(
                                'Time: ${order['orderTime']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Status: ${order['status']}',
                                style: TextStyle(
                                  color: _getStatusColor(order['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailPage(orderData: order),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.green;
      case 'Delivering':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
