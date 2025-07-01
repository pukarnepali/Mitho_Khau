import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  Future<Map<String, dynamic>> _prepareOrderData(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return {};

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};
    final userName = userData['username'] ?? 'Unknown';
    final userAddress = userData['address'] ?? 'No address provided';

    final orderItems = cartProvider.items.map<Map<String, dynamic>>((item) {
      final food = item['food'];
      final quantity = item['quantity'];
      return {
        'itemName': food.name,
        'quantity': quantity,
        'itemPrice': food.price,
        'total': food.price * quantity,
      };
    }).toList();

    final totalAmount = cartProvider.totalAmount;
    final orderTime = Timestamp.now();

    final orderData = {
      'userId': user.uid,
      'userName': userName,
      'userAddress': userAddress,
      'items': orderItems,
      'totalAmount': totalAmount,
      'orderTime': orderTime,
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
    return orderData;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return PopScope(
      canPop: false, // Prevent default back navigation
      // prevent the default pop

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Order Receipt",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
          elevation: 0,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _prepareOrderData(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = snapshot.data!;
            final items = order['items'] as List<dynamic>;
            final orderTime = (order['orderTime'] as Timestamp).toDate();
            final formattedTime =
                DateFormat('yyyy-MM-dd – hh:mm a').format(orderTime);
            final estimatedDeliveryTime =
                orderTime.add(const Duration(minutes: 20));
            final formattedDeliveryTime = DateFormat('yyyy-MM-dd – hh:mm a')
                .format(estimatedDeliveryTime);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thank you, ${order['userName']}!',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Order Time:", formattedTime),
                          const SizedBox(height: 8),
                          _infoRow(
                              "Estimated Delivery:", formattedDeliveryTime),
                          const SizedBox(height: 8),
                          _infoRow("Delivery Address:", order['userAddress']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Order Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text('${item['quantity']}x'),
                            ),
                            title: Text(item['itemName'],
                                style: const TextStyle(fontSize: 16)),
                            trailing: Text(
                                'Rs. ${(item['total']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Rs. ${order['totalAmount'].toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () {
                        cartProvider.clearCart();
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      },
                      icon: const Icon(Icons.home),
                      label: const Text(
                        "Back to Home",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 16, height: 1.5)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 16, height: 1.5),
              overflow: TextOverflow.visible),
        ),
      ],
    );
  }
}
