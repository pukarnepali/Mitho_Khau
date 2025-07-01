import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailPage({super.key, required this.orderData});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _isUpdating = false;
  bool _isLoadingUserData = true;

  String _phone = '';
  String _addressType = '';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userName = widget.orderData['customer'];

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: userName)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userDoc = userSnapshot.docs.first;

        setState(() {
          _phone = userDoc['phone'] ?? '';
          _addressType = userDoc['addressType'] ?? '';
          _city = userDoc['city'] ?? '';
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _markAsReceived() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final orderId = widget.orderData['orderId'];

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Received'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as Received.')),
      );

      setState(() {
        widget.orderData['status'] = 'Received';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.orderData['orderItems'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Info",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Name: ${widget.orderData['customer']}"),
            _isLoadingUserData
                ? const CircularProgressIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: $_phone"),
                      Text("Address: ${widget.orderData['address']}"),
                      Text("Address Type: $_addressType"),
                      Text("City: $_city"),
                    ],
                  ),
            const Divider(height: 30),
            const Text(
              "Order Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Order ID: ${widget.orderData['orderId']}"),
            Text("Order Time: ${widget.orderData['orderTime']}"),
            Text("Status: ${widget.orderData['status']}"),
            Text(
              "Total Price: Rs. ${widget.orderData['totalPrice']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            const Text(
              "Ordered Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item['name'] ?? 'Confidential'),
                subtitle: Text(
                    "Qty: ${item['quantity']}, Price: Rs. ${item['price']}"),
              );
            }).toList(),
            const SizedBox(height: 30),
            if (widget.orderData['status'] == 'Delivering')
              Center(
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _markAsReceived,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Mark as Received",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
