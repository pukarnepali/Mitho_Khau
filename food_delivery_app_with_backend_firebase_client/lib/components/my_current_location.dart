import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCurrentLocation extends StatelessWidget {
  MyCurrentLocation({super.key});

  // Function to fetch address from Firestore
  Future<String> fetchAddress() async {
    try {
      // Get the current user's UID
      String? userUid = FirebaseAuth.instance.currentUser?.uid;

      if (userUid == null) {
        throw 'User UID is null'; // Error if no user is logged in
      }

      // Fetch user data from Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid) // Use the current user's UID
          .get();

      if (!userDoc.exists) {
        throw 'No user document found'; // Error if user document is not found
      }

      // Extract the address field and handle null or empty cases
      String? fetchedAddress = userDoc.data()?['address'];

      if (fetchedAddress != null && fetchedAddress.isNotEmpty) {
        return fetchedAddress;
      } else {
        return 'No address available'; // Fallback if no address is set
      }
    } catch (e) {
      return 'Error: $e'; // Catch and display the error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deliver Now',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          GestureDetector(
            onTap: () {},
            child: FutureBuilder<String>(
              future: fetchAddress(), // Fetch address asynchronously
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Show error message
                }

                if (snapshot.hasData) {
                  // Display the fetched address or fallback message
                  return Row(
                    children: [
                      Text(
                        snapshot.data ?? 'No address available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  );
                }

                return const Text('No address available');
              },
            ),
          ),
        ],
      ),
    );
  }
}
