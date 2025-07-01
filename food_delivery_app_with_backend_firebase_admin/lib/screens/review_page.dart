import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewManagementScreen extends StatefulWidget {
  const ReviewManagementScreen({super.key});

  @override
  _ReviewManagementScreenState createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen> {
  // Method to delete the review from Firestore
  Future<void> _deleteReview(String reviewId) async {
    try {
      // Delete review from Firestore
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete review: $e')),
      );
    }
  }

  // Method to confirm before deleting the review
  Future<void> _showDeleteConfirmation(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteReview(reviewId);
    }
  }

  // Method to fetch food details using foodId
  Future<String> _getFoodName(String foodId) async {
    print('Fetching food name for foodId: $foodId'); // Debugging line

    try {
      final foodDoc = await FirebaseFirestore.instance
          .collection('foods')
          .doc(foodId)
          .get();

      if (foodDoc.exists) {
        print('Food document found: ${foodDoc.data()}'); // Log food data
        return foodDoc['name']; // assuming the food document has a 'name' field
      } else {
        print('No food document found for foodId: $foodId'); // Log if not found
        return 'Unknown Food';
      }
    } catch (e) {
      print('Error fetching food name: $e'); // Log any error
      return 'Unknown Food';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Management'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data?.docs ?? [];

          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final reviewId = review.id;
              final foodId = review['foodId'];
              final username = review['username'];
              final reviewText = review['review'];
              final timestamp = (review['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy').format(timestamp);

              return FutureBuilder<String>(
                future: _getFoodName(foodId),
                builder: (context, foodSnapshot) {
                  if (foodSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading food name...'),
                      subtitle: Text('Review loading...'),
                    );
                  }

                  final foodName = foodSnapshot.data ?? 'Unknown Food';

                  return Dismissible(
                    key: Key(reviewId),
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _showDeleteConfirmation(reviewId);
                    },
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(username),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Review: $reviewText'),
                          Text('Food: $foodName'),
                        ],
                      ),
                      trailing: Text(formattedDate,
                          style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        // Optional: Add an action if needed (e.g., view review details).
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
