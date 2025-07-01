import 'package:flutter/material.dart';
import 'dart:async';
import 'receipt_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _showProgress = true; // To show the CircularProgressIndicator
  bool _showCheckmark = false; // To show the checkmark icon
  bool _showText = false; // To show the "Payment Successful!" text

  @override
  void initState() {
    super.initState();

    // First, show the progress indicator for 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showProgress = false; // Hide the progress bar
        _showCheckmark = true; // Show the checkmark icon
      });

      // Then, show the checkmark icon for 2 seconds with bounce effect
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showText = true; // Show the text after checkmark
        });
      });

      // Delay the navigation to ReceiptPage after 5 seconds in total
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ReceiptPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Stage 1: CircularProgressIndicator (2 seconds)
            _showProgress
                ? CircularProgressIndicator(
                    color: Colors.white,
                  )
                : SizedBox.shrink(),

            // Stage 2: Animated Checkmark (2 seconds after progress bar)
            AnimatedOpacity(
              opacity: _showCheckmark ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 1.5),
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
                onEnd: () {
                  // Trigger bounce effect after the scaling is done
                  setState(() {
                    _showCheckmark = true;
                  });
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: AnimatedScale(
                  scale: _showCheckmark ? 1.5 : 1.0,
                  duration: Duration(seconds: 1),
                  curve: Curves.bounceOut, // Bounce effect
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),

            SizedBox(height: 45),

            // Stage 3: Animated Text "Payment Successful!" (2 seconds after checkmark)
            AnimatedOpacity(
              opacity: _showText ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: AnimatedScale(
                scale: _showText ? 1.5 : 1.0,
                duration: Duration(seconds: 1),
                child: Text(
                  "Payment Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
