import 'package:flutter/material.dart';
import 'package:food_delivery_app_with_backend_firebase_client/components/intro_Slider.dart';
import 'package:provider/provider.dart';

import '../provider/category_provider.dart';
import '../models/food_item.dart';
import '../components/my_drawer.dart';
import '../components/my_sliver_app_bar.dart';
import '../components/my_tab_bar.dart';
import '../components/my_description_box.dart';
import 'food_details_screen.dart';

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
          _tabController = TabController(
            length: provider.categories.length,
            vsync: this,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    if (_tabController == null || menuProvider.categories.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categoryNames = menuProvider.categories.map((c) => c.name).toList();

    return Scaffold(
      backgroundColor: Color(0xFFFFA000),
      extendBodyBehindAppBar: true,
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
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
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            const MySliverAppBar(),
          ],
          body: Column(
            children: [
              // const SizedBox(height: 8),
              // const MyDescriptionBox(),
              const IntroSlider(),
              // const SizedBox(height: 8),
              MyTabBar(
                tabController: _tabController!,
                categoryNames: categoryNames,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: menuProvider.categories.map((category) {
                    final foodItems =
                        menuProvider.getItemsByCategory(category.id);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
                        itemCount: foodItems.length + 1, // +1 for recommended
                        itemBuilder: (context, index) {
                          if (index < foodItems.length) {
                            final food = foodItems[index];
                            return _buildFoodListTile(context, food);
                          } else {
                            // final recommended = menuProvider.items.isNotEmpty
                            //     ? menuProvider.items.first
                            //     : null;
                            final recommendedItems =
                                menuProvider.items.take(3).toList();

                            if (recommendedItems.isEmpty)
                              return const SizedBox();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  'Recommended For You',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // _buildRecommendedItemCard(),
                                ...recommendedItems
                                    .map(_buildRecommendedItemCard)
                                    .toList(),
                              ],
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodListTile(BuildContext context, FoodItem food) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            food.imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          food.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          'NPR ${food.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(food: food),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedItemCard(FoodItem food) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(food: food),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                food.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NPR ${food.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
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
