import 'package:flutter/material.dart';
import 'package:food_delivery_app_with_backend_firebase_client/pages/add_address.dart';
import 'package:food_delivery_app_with_backend_firebase_client/pages/credit_card_page.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();
  bool _isApplying = false;

  Future<void> _applyCoupon(BuildContext context) async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.isCouponUsed(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This coupon has already been used.')),
      );
      return;
    }

    setState(() => _isApplying = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final discount = snapshot.docs.first['discount'] as int;

        if (cart.appliedCoupon == null) {
          cart.applyCoupon(code, discount.toDouble());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coupon applied: $discount% off!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A coupon is already applied!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error applying coupon')),
      );
    } finally {
      setState(() => _isApplying = false);
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: Color(0xFFFFA000),
      appBar: AppBar(
        title: const Text(
          "Your Cart",
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
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.deepOrangeAccent],
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
        child: Column(
          children: [
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:
                          _isApplying ? null : () => _applyCoupon(context),
                      child: _isApplying
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('Your cart is empty!',
                          style:
                              TextStyle(fontSize: 20, color: Colors.black54)),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                          key: Key(item['food'].name),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            cartProvider.removeItem(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Item removed from cart')),
                            );
                          },
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['food'].imagePath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fastfood,
                                    size: 60,
                                    color: Colors.black26,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['food'].name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                  'Quantity: ${item['quantity'].toString()}'),
                              trailing: Text(
                                'NPR ${(item['food'].price * item['quantity']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12.0,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cartProvider.appliedCoupon != null
                            ? 'Discount (${cartProvider.appliedCoupon}): -${cartProvider.discountPercentage.toInt()}%\nTotal: NPR ${cartProvider.totalAmount.toStringAsFixed(2)}'
                            : 'Total: NPR ${cartProvider.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final cart =
                              Provider.of<CartProvider>(context, listen: false);
                          if (cart.appliedCoupon != null) {
                            cart.markCouponUsed(cart.appliedCoupon!);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressEntryPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Add Address',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 6.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
