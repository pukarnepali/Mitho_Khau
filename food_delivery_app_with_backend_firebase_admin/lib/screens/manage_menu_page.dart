import 'package:flutter/material.dart';
import '../widgets/category_form.dart';
import '../widgets/food_item_form.dart';

class MenuActionsScreen extends StatelessWidget {
  const MenuActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍽️ Manage Menu'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          children: [
            _actionCard(
              context,
              title: 'Add Category',
              subtitle:
                  'Create new food categories like appetizers,\nmain courses, and desserts.',
              icon: Icons.category,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CategoryForm(),
                );
              },
            ),
            const SizedBox(height: 16),
            _actionCard(
              context,
              title: 'Add Food Item',
              subtitle: 'Add new dishes to your menu quickly.',
              icon: Icons.fastfood,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => FoodItemForm(),
                );
              },
            ),
            const SizedBox(height: 16),
            _actionCard(
              context,
              title: 'View Added Items',
              subtitle: 'Review and manage existing menu items.',
              icon: Icons.view_list,
              onTap: () {
                Navigator.pushNamed(context, '/view-items');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.5),
            style: BorderStyle.solid, // use dotted manually if needed
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blueAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
