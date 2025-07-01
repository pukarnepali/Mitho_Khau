import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _showFeedbackDialog() async {
    double deliveryRating = 3;
    double foodRating = 3;
    double appRating = 3;
    String comment = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Submit Feedback'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRatingRow('Delivery Service', deliveryRating,
                      (value) => setState(() => deliveryRating = value)),
                  _buildRatingRow('Food Quality', foodRating,
                      (value) => setState(() => foodRating = value)),
                  _buildRatingRow('App Experience', appRating,
                      (value) => setState(() => appRating = value)),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) => comment = value,
                    decoration: const InputDecoration(
                      labelText: 'Additional Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final currentUser = _auth.currentUser;
                  if (currentUser == null) return;

                  final userDoc = await _firestore
                      .collection('users')
                      .doc(currentUser.uid)
                      .get();

                  final username = userDoc.data()?['username'] ?? 'Anonymous';

                  await _firestore.collection('feedbacks').add({
                    'username': username,
                    'deliveryRating': deliveryRating,
                    'foodRating': foodRating,
                    'appRating': appRating,
                    'comment': comment,
                    'timestamp': Timestamp.now(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback submitted')),
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildRatingRow(
    String label,
    double rating,
    void Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: rating,
          min: 1,
          max: 5,
          divisions: 4,
          label: rating.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.deepOrangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'User Feedback',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 1),
                blurRadius: 4,
              )
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showFeedbackDialog,
        child: const Icon(Icons.feedback),
      ),
      body: Container(
        decoration: BoxDecoration(
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('feedbacks')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading feedbacks'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbacks = snapshot.data?.docs ?? [];

            if (feedbacks.isEmpty) {
              return const Center(child: Text('No feedback yet.'));
            }

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final data = feedbacks[index].data() as Map<String, dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      data['username'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery: ${data['deliveryRating']} | '
                          'Food: ${data['foodRating']} | '
                          'App: ${data['appRating']}',
                        ),
                        if ((data['comment'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('“${data['comment']}”'),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            (data['timestamp'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 16),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
