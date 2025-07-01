import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'credit_card_page.dart';

class AddressEntryPage extends StatefulWidget {
  const AddressEntryPage({super.key});

  @override
  _AddressEntryPageState createState() => _AddressEntryPageState();
}

class _AddressEntryPageState extends State<AddressEntryPage> {
  final _addressController = TextEditingController();
  final _addressTypeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _addressTypeController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final address = _addressController.text.trim();
    final addressType = _addressTypeController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();

    if (address.isEmpty ||
        addressType.isEmpty ||
        phone.isEmpty ||
        city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields must be filled out')));
      return;
    }

    try {
      // Update the user's address details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'address': address,
        'addressType': addressType,
        'phone': phone,
        'city': city,
      });

      // Navigate to the payment page
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PaymentPage()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA000),
      appBar: AppBar(
        title: const Text(
          "Enter Your Address",
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.deepOrangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Please enter your delivery address:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Address',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your complete address',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Address Type (Home, Office, etc.)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter type of address',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your phone number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City/Region',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your city or region',
                  ),
                ),
                const SizedBox(height: 10),
                // TextField(
                //   controller: _postalCodeController,
                //   decoration: const InputDecoration(
                //     labelText: 'Postal Code/Zip Code',
                //     border: OutlineInputBorder(),
                //     hintText: 'Enter postal code',
                //   ),
                //   keyboardType: TextInputType.number,
                // ),
                const SizedBox(height: 200),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6.0,
                    ),
                    onPressed: () => _updateAddress(context),
                    child: const Text(
                      "Place Order",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
