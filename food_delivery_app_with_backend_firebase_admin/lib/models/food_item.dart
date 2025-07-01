class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final String categoryId;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'price': price,
        'categoryId': categoryId,
      };

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        imagePath: map['imagePath'],
        price: (map['price'] as num).toDouble(),
        categoryId: map['categoryId'],
      );

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    double? price,
    String? categoryId,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
