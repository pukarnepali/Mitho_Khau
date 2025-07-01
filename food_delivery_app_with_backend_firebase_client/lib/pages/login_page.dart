// ignore_for_file: use_build_context_synchronously, unused_catch_clause

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app_with_backend_firebase_client/pages/forget_password.dart';
// import 'package:food_delivery_app/components/my_button.dart';
// import 'package:food_delivery_app/components/my_text_field.dart';
// import 'package:food_delivery_app/pages/home_page.dart';
// import 'package:food_delivery_app/pages/register_page.dart';
import 'package:food_delivery_app_with_backend_firebase_client/pages/home_page.dart';
import 'package:lottie/lottie.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onTap,
  });

  final Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  void signUserIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        );
      },
    );

    // Try sign in
    try {
      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Pop the loading circle after successful sign-in
      Navigator.pop(context);

      // Check if user is signed in and navigate to Home Page
      if (FirebaseAuth.instance.currentUser != null) {
        // Navigate to Home Page after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ViewMenuItemsScreen()), // Replace `HomePage()` with your actual home page widget
        );
      }
    } on FirebaseAuthException catch (e) {
      // Pop the loading circle if error occurs
      Navigator.pop(context);

      // Show alert dialog with error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sign in Failed'),
            content: const Text('Username Or Password Incorrect'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the alert dialog
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
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //logo
                  LottieBuilder.asset(
                    'animation/loginburger.json',
                    repeat: true,
                  ),

                  // const SizedBox(height: 5),

                  //message,app slogan
                  Text(
                    'Welcome to Mitho Khau',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 25),

                  //email textfield

                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscuretext: false,
                  ),

                  const SizedBox(height: 10),

                  //password textfield
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

                  const SizedBox(height: 25),

                  //sign in button

                  Mybutton(
                    ontap: signUserIn,
                    text: 'Login',
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  //not a member? register now

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member? ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RegisterPage(onTap: () {}),
                              ),
                            );
                          },
                          child: const Text(
                            'Register Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
