import 'package:flutter/material.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  double _discountPercentage = 0;
  String? _appliedCoupon;
  final Set<String> _usedCoupons = {};

  List<Map<String, dynamic>> get items => _items;
  double get discountPercentage => _discountPercentage;
  String? get appliedCoupon => _appliedCoupon;
  Set<String> get usedCoupons => _usedCoupons;

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item['food'].price * item['quantity'];
    }
    return total * (1 - _discountPercentage / 100);
  }

  void addItem(FoodItem food, int quantity) {
    final index = _items.indexWhere((item) => item['food'].id == food.id);
    if (index >= 0) {
      _items[index]['quantity'] += quantity;
    } else {
      _items.add({'food': food, 'quantity': quantity});
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void applyCoupon(String code, double percentage) {
    _discountPercentage = percentage;
    _appliedCoupon = code;
    notifyListeners();
  }

  void markCouponUsed(String code) {
    _usedCoupons.add(code);
    _discountPercentage = 0;
    _appliedCoupon = null;
    notifyListeners();
  }

  bool isCouponUsed(String code) {
    return _usedCoupons.contains(code);
  }

  // void clearCoupon() {
  //   _discountPercentage = 0;
  //   _appliedCoupon = null;
  //   notifyListeners();
  // }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
