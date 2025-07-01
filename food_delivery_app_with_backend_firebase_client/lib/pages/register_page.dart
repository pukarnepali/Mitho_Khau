import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
// import 'package:food_delivery_app/components/my_button.dart';
// import 'package:food_delivery_app/components/my_text_field.dart';
// import 'package:food_delivery_app/pages/login_page.dart';
import 'package:lottie/lottie.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  final Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final TextEditingController usernameController =
      TextEditingController(); // Username controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confiremPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Visibility state for password and confirm password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Authentication
  void signUserUp() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Try sign up
    try {
      if (passwordController.text == confiremPasswordController.text) {
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Add the user to Firestore with username
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'username': usernameController.text, // Save the username
          'email': emailController.text,
          'password': passwordController
              .text, // You might not want to store the password in plaintext
          'address': addressController.text, // Save address
          'phone': phoneController.text, // Save phone number
        });

        // Pop the loading circle
        Navigator.pop(context);

        // Show a success message (optional)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully!')),
        );

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(onTap: () {}),
          ),
        );
      } else {
        // Pop the loading circle and show error if passwords don't match
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Passwords do not match'),
              content: const Text(
                  'Please check your password and confirm password fields.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle and show error message
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Register Failed'),
            content: Text(e.message ?? 'An error occurred. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFFA000),
        // backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          decoration: const BoxDecoration(
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  LottieBuilder.asset(
                    'animation/loginburger.json',
                    repeat: true,
                  ),

                  // Message, app slogan
                  Text(
                    "Let's create an account for you",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Username text field
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscuretext: false,
                  ),
                  const SizedBox(height: 10),
                  // Address text field
                  MyTextField(
                    controller: addressController,
                    hintText: 'Delivery Address',
                    obscuretext: false,
                  ),
                  const SizedBox(height: 10),

                  // Phone number text field
                  MyTextField(
                    controller: phoneController,
                    hintText: 'Phone Number',
                    obscuretext: false,
                  ),
                  const SizedBox(height: 10),
                  // Email text field
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscuretext: false,
                  ),
                  const SizedBox(height: 10),

                  // Password text field with visibility toggle
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscuretext: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm password text field
                  MyTextField(
                    controller: confiremPasswordController,
                    hintText: 'Confirm Password',
                    obscuretext: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Register button
                  Mybutton(
                    ontap: signUserUp,
                    text: 'Register',
                  ),

                  const SizedBox(height: 10),

                  // Already have an account? Login here
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black,
                            // color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(onTap: () {}),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
