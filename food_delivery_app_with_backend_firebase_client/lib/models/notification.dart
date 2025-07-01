import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final String couponCode;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.couponCode,
  });

  // Method to create a Notification object from Firestore document data
  factory Notification.fromFirestore(DocumentSnapshot doc) {
    return Notification(
      id: doc.id,
      title: doc['title'],
      message: doc['message'],
      couponCode: doc['couponCode'],
    );
  }
}
