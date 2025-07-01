import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PushNotificationPage extends StatelessWidget {
  const PushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Offer Notification'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No notifications sent yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final message = doc['message'];
              final coupon = doc['coupon'];

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) {
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(doc.id)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text(message),
                    subtitle: Text('Coupon: $coupon'),
                    trailing: const Icon(Icons.local_offer, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert),
        label: const Text("Send Offer"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const NotificationDialog(),
          );
        },
      ),
    );
  }
}

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Offer Notification'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: couponController,
              decoration: const InputDecoration(
                labelText: 'Coupon Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Send'),
          onPressed: () async {
            final message = messageController.text.trim();
            final coupon = couponController.text.trim();

            if (message.isEmpty || coupon.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in both fields.')),
              );
              return;
            }

            await FirebaseFirestore.instance.collection('notifications').add({
              'message': message,
              'coupon': coupon,
              'timestamp': DateTime.now(),
            });

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification stored!')),
            );
          },
        ),
      ],
    );
  }
}
