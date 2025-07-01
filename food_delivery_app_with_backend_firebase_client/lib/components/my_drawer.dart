import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/about_us.dart';
import '../pages/favorites_page.dart';
import '../pages/feedback_page.dart';
import '../pages/order_history.dart';
import '../pages/settings_page.dart';
import '../pages/notification_page.dart'; // Import the notification page
import 'my_drawer_tile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void signUserout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.deepOrangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Image(
                      image: AssetImage('images/mithokhau-logo-light.png'),
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mitho Khau',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(color: Colors.white.withOpacity(0.3)),
              ),
              const SizedBox(height: 10),

              // Menu options
              MyDrawerTile(
                icon: Icons.home,
                text: 'H o m e',
                color: Colors.white,
                ontap: () => Navigator.pop(context),
              ),
              MyDrawerTile(
                icon: Icons.history,
                text: 'O r d e r  H i s t o r y',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage()),
                  );
                },
              ),
              MyDrawerTile(
                icon: Icons.settings,
                text: 'S e t t i n g s',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),

              // New "Notifications" tile
              MyDrawerTile(
                icon: Icons.notifications,
                text: 'N o t i f i c a t i o n s',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  );
                },
              ),
              MyDrawerTile(
                icon: Icons.favorite,
                text: 'F a v o r i t e s',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritePage()),
                  );
                },
              ),
              MyDrawerTile(
                icon: Icons.feedback,
                text: 'F e e d b a c k',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackPage()),
                  );
                },
              ),
              MyDrawerTile(
                icon: Icons.info_outline,
                text: 'A b o u t  U s',
                color: Colors.white,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUs()),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(color: Colors.white.withOpacity(0.3)),
              ),
              MyDrawerTile(
                icon: Icons.logout_outlined,
                text: 'L o g o u t',
                color: Colors.white,
                ontap: signUserout,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
