import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderProvider with ChangeNotifier {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> placeOrder({
    required String userName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    final orderData = {
      'userName': userName,
      'totalAmount': totalAmount,
      'timestamp': DateTime.now().toIso8601String(),
      'items': items.map((item) {
        return {
          'name': item['food'].name,
          'quantity': item['quantity'],
          'price': item['food'].price,
        };
      }).toList(),
    };

    try {
      await _db.child('orders').push().set(orderData);
      debugPrint('Order placed successfully!');
    } catch (e) {
      debugPrint('Failed to place order: $e');
      rethrow;
    }
  }
}
