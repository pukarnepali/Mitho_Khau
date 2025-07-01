import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailPage({super.key, required this.order});

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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    final formatter = DateFormat('yyyy/MM/dd – hh:mm a');
    return formatter.format(dateTime);
  }

  Future<void> _updateStatusToDelivering(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order['orderId'])
          .update({'status': 'Delivering'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated to Delivering')),
      );

      Navigator.pop(context); // Go back to refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = order['orderItems'] as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 180, // Fixed height
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Text('Order ID: ${order['orderId']}',
                      //     style: const TextStyle(
                      //         fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Customer: ${order['customer']}'),
                      Text(
                        'Address: ${order['address']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text('Date: ${_formatDateTime(order['orderTime'])}'),
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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ordered Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  final item = orderItems[index];
                  return ListTile(
                    title: Text(item['itemName']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Text('Npr ${item['itemPrice']}'),
                  );
                },
              ),
            ),
            const Divider(height: 24, thickness: 1),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: Npr ${order['totalPrice']}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            if (order['status'] == 'Pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('Mark as Delivering'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _updateStatusToDelivering(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
