import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/manage_menu_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/push_notification_page.dart';
import 'package:food_delivery_app_with_backend_firebase_admin/screens/view_menu_item.dart';
import 'package:provider/provider.dart';
import 'screens/login_page.dart';
import 'providers/menu_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase before running the app
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(onTap: null),
        '/menu-actions': (context) => const MenuActionsScreen(),
        '/view-items': (context) => const ViewMenuItemsScreen(),
        '/push-notification': (context) => const PushNotificationPage(),
      },
    );
  }
}
