import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_details.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> userList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        userList.add({
          'userId': doc.id,
          'username': data['username'] ?? 'Unknown',
          'email': data['email'] ?? 'Unknown',
          'phone': data['phone'] ?? 'Unknown',
          'address': data['address'] ?? 'No Address Provided',
        });
      }

      setState(() {
        users = userList;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> deleteUser(String userId, int index) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      setState(() {
        users.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Users Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Dismissible(
                          key: Key(user['userId']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => deleteUser(user['userId'], index),
                          child: Card(
                            child: ListTile(
                              title: Text(user['username']),
                              subtitle: Text(
                                'Email: ${user['email']}\nPhone: ${user['phone']}\nAddress: ${user['address']}',
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserDetailsPage(user: user),
                                  ),
                                );
                              },
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
}
