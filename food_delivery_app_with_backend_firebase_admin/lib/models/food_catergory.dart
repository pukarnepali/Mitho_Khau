// models/food_category.dart
import 'food_item.dart';

class FoodCategory {
  final String id;
  final String name;
  List<FoodItem> foodItems; // Added foodItems list

  FoodCategory({
    required this.id,
    required this.name,
    this.foodItems = const [], // Initialize with an empty list
  });

  // Method to add food items to this category
  void addFoodItem(FoodItem foodItem) {
    foodItems.add(foodItem);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'foodItems': foodItems.map((item) => item.toMap()).toList(),
      };

  factory FoodCategory.fromMap(Map<String, dynamic> map) {
    return FoodCategory(
      id: map['id'],
      name: map['name'],
      foodItems: (map['foodItems'] as List)
          .map((itemMap) => FoodItem.fromMap(itemMap))
          .toList(),
    );
  }
}
