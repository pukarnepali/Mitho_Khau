import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_categories.dart';
import '../models/food_item.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FoodCategory> _categories = [];
  List<FoodItem> _items = [];

  List<FoodCategory> get categories => _categories;
  List<FoodItem> get items => _items;

  // Fetch categories from Firestore
  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories =
          snapshot.docs.map((doc) => FoodCategory.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Fetch food items from Firestore
  Future<void> fetchItems() async {
    try {
      final snapshot = await _firestore.collection('items').get();
      _items =
          snapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  // Add a category to Firestore
  Future<void> addCategory(String name) async {
    try {
      final doc = _firestore.collection('categories').doc();
      final newCategory = FoodCategory(id: doc.id, name: name);
      await doc.set(newCategory.toMap());
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  // Add a food item to Firestore
  Future<void> addItem(FoodItem item) async {
    try {
      final doc = _firestore.collection('items').doc();
      final newItem = item.copyWith(id: doc.id);
      await doc.set(newItem.toMap());
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  // Fetch both categories and food items
  Future<void> fetchMenuData() async {
    try {
      final catSnapshot = await _firestore.collection('categories').get();
      final itemSnapshot = await _firestore.collection('items').get();

      _categories = catSnapshot.docs
          .map((doc) => FoodCategory.fromMap(doc.data()))
          .toList();
      _items =
          itemSnapshot.docs.map((doc) => FoodItem.fromMap(doc.data())).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching menu data: $e');
    }
  }

  // Get food items by category
  List<FoodItem> getItemsByCategory(String categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }
}
