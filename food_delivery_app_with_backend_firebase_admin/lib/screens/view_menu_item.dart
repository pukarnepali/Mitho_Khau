import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/menu_provider.dart';
import '../models/food_item.dart';

class ViewMenuItemsScreen extends StatefulWidget {
  const ViewMenuItemsScreen({super.key});

  @override
  State<ViewMenuItemsScreen> createState() => _ViewMenuItemsScreenState();
}

class _ViewMenuItemsScreenState extends State<ViewMenuItemsScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MenuProvider>(context, listen: false);
    provider.fetchMenuData().then((_) {
      if (mounted) {
        setState(() {
          _tabController =
              TabController(length: provider.categories.length, vsync: this);
        });
      }
    });
  }

  // Function to show confirmation dialog for deleting an item
  Future<void> _confirmDelete(FoodItem foodItem) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${foodItem.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Proceed with delete operation
      await _deleteItem(foodItem.id);
    }
  }

  // Function to delete the item
  Future<void> _deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
      // Remove the item from the local list
      Provider.of<MenuProvider>(context, listen: false).fetchMenuData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting item')),
      );
    }
  }

  // Function to show confirmation dialog for editing an item
  Future<void> _confirmEdit(FoodItem foodItem) async {
    final shouldEdit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Text('Do you want to edit "${foodItem.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );

    if (shouldEdit == true) {
      // Proceed with edit operation
      _editItem(foodItem);
    }
  }

  // Function to edit an item (can be expanded with a proper editing screen)
  Future<void> _editItem(FoodItem item) async {
    final nameController = TextEditingController(text: item.name);
    final descController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final imageController = TextEditingController(text: item.imagePath);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${item.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedItem = item.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ??
                        item.price,
                    imagePath: imageController.text.trim(),
                  );

                  await FirebaseFirestore.instance
                      .collection('items')
                      .doc(item.id)
                      .update(updatedItem.toMap());

                  // Refresh the local list
                  await Provider.of<MenuProvider>(context, listen: false)
                      .fetchMenuData();

                  if (mounted) Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Menu Items'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: menuProvider.categories.isEmpty || _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: menuProvider.categories
                      .map((c) => Tab(text: c.name))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: menuProvider.categories.map((category) {
                      final foodItems =
                          menuProvider.getItemsByCategory(category.id);
                      return ListView.builder(
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          final food = foodItems[index];
                          return Dismissible(
                            key: Key(food.id), // Unique key for each item
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                // Swipe Left -> Delete
                                await _confirmDelete(food);
                                return false;
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                // Swipe Right -> Edit
                                await _confirmEdit(food);
                                return false;
                              }
                              return false;
                            },
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                            child: ListTile(
                              leading: Image.network(
                                food.imagePath,
                                width: 50,
                                height: 50,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.fastfood),
                              ),
                              title: Text(food.name),
                              subtitle: Text(food.description),
                              trailing:
                                  Text('\Npr ${food.price.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
    );
  }
}
