import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CouponForm extends StatefulWidget {
  @override
  _CouponFormState createState() => _CouponFormState();
}

class _CouponFormState extends State<CouponForm> {
  final _firestore = FirebaseFirestore.instance;
  String? _couponCode;
  int _discountPercentage = 5;
  List<Map<String, dynamic>> _coupons = [];

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  // Function to fetch existing coupons from Firestore
  Future<void> _fetchCoupons() async {
    QuerySnapshot snapshot = await _firestore.collection('coupons').get();
    setState(() {
      _coupons = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'code': doc['code'],
                'discount': doc['discount'],
              })
          .toList();
    });
  }

  // Function to generate a random 6-character coupon code
  String _generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  // Function to add a coupon to Firestore
  Future<void> _addCoupon() async {
    String couponCode = _generateCouponCode();
    await _firestore.collection('coupons').add({
      'code': couponCode,
      'discount': _discountPercentage,
    });
    _fetchCoupons(); // Refresh the coupons list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon $couponCode added!')),
    );
  }

  // Function to delete a coupon from Firestore
  Future<void> _deleteCoupon(String couponId) async {
    await _firestore.collection('coupons').doc(couponId).delete();
    _fetchCoupons(); // Refresh the coupons list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coupon deleted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Coupons'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCoupon,
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Generate a New Coupon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              value: _discountPercentage,
              onChanged: (value) {
                setState(() {
                  _discountPercentage = value!;
                });
              },
              items: [5, 10, 15, 20]
                  .map((discount) => DropdownMenuItem<int>(
                        value: discount,
                        child: Text('$discount%'),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Current Coupons:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _coupons.length,
                itemBuilder: (context, index) {
                  final coupon = _coupons[index];
                  return Dismissible(
                    key: Key(coupon['id']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteCoupon(coupon['id']);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(coupon['code']),
                        subtitle: Text('Discount: ${coupon['discount']}%'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
