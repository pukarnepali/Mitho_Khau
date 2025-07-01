import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/admin_order_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/coupons.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/manage_menu_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/push_notification_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/review_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/view_menu_item.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import 'analytics_page.dart';
import 'feedback.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> recentOrders = [];

  int totalOrders = 0;
  double totalRevenue = 0.0;
  int activeItems = 0;
  int ongoingOrders = 0;

  @override
  void initState() {
    super.initState();
    fetchRecentOrders();
    fetchDashboardStats();
  }

  Future<void> fetchRecentOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('orderTime', descending: false)
          .limit(4)
          .get();

      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'];

        // Fetch user name
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final customerName = userDoc.data()?['username'] ?? 'Unknown';

        final items = data['items'];
        final itemName = items.isNotEmpty ? items[0]['itemName'] : 'N/A';

        orders.add({
          'orderId': doc.id,
          'itemName': itemName,
          'status': data['status'] ?? 'Pending',
          'customer': customerName,
        });
      }

      setState(() {
        recentOrders = orders;
      });
    } catch (e) {
      print('Error fetching recent orders: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final itemsSnapshot = await _firestore.collection('items').get();

      int total = ordersSnapshot.docs.length;
      double revenue = 0;
      int ongoing = 0;

      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        revenue += (data['totalAmount'] ?? 0.0);
        final status = data['status'] ?? '';
        if (status == 'Pending' && status == 'Delivering') {
          ongoing += 1;
        }
      }

      setState(() {
        totalOrders = total;
        totalRevenue = revenue;
        ongoingOrders = ongoing;
        activeItems = itemsSnapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Handle logout
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  children: [
                    Image(
                        height: 100,
                        image: AssetImage(
                            'assets/images/mithokhau-logo-light.png')),
                    Text("Mitho Khau Admin Panel")
                  ],
                )
                //
                // Text('Admin Menu',
                //     style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminOrdersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Manage Menu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => MenuProvider(),
                      child: const MenuActionsScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Add Coupons'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CouponForm(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Offer for customer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PushNotificationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reviews),
              title: const Text('Food Reviews'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.reviews),
              title: const Text('Feedbacks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminFeedbackPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Total Orders', totalOrders.toString(),
                    Icons.shopping_cart),
                _buildInfoCard(
                  'Revenue',
                  'NPR ${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewMenuItemsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 2.2,
                    child: _buildInfoCard('Active Items',
                        activeItems.toString(), Icons.food_bank),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOrdersPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 2.2,
                    child: _buildInfoCard('Ongoing Orders',
                        ongoingOrders.toString(), Icons.timer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Recent Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: recentOrders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: recentOrders.length,
                      itemBuilder: (context, index) {
                        final order = recentOrders[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: Text(order['itemName']),
                            subtitle: Text('Customer: ${order['customer']}'),
                            trailing: Text(
                              order['status'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(order['status']),
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
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.green;
      case 'Delivering':
        return Colors.orange;
      case 'Canceled':
        return Colors.black;
      case 'Pending':
      default:
        return Colors.red;
    }
  }
}
