import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import 'full_screen_payment_success .dart';
import 'receipt_page.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _creditFormKey = GlobalKey<FormState>();
  final _esewaFormKey = GlobalKey<FormState>();

  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _esewaPhoneController = TextEditingController();

  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _confirmationCode = '';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _esewaPhoneController.dispose();
    super.dispose();
  }

  TextInputFormatter _cardNumberFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'\D'), '');
      String formatted = '';
      for (int i = 0; i < text.length; i += 4) {
        formatted +=
            text.substring(i, (i + 4) > text.length ? text.length : i + 4);
        if (i + 4 < text.length) formatted += ' ';
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  TextInputFormatter _expiryDateFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'\D'), '');
      String formatted = '';
      if (text.length > 2) {
        formatted = text.substring(0, 2) + '/' + text.substring(2);
      } else {
        formatted = text;
      }
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalAmount = cartProvider.totalAmount;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFFFFA000),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.deepOrangeAccent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "Payment",
            style: const TextStyle(
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
          backgroundColor: Colors.blueGrey.shade700,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Credit Card'),
              Tab(text: 'eSewa'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              // Color(0xFFFDEB71),
              Color(0xFFF8D800),
              Color(0xFFFFC107),
              Color(0xFFFFA000),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 0.6, 1.0],
          )),
          child: TabBarView(
            children: [
              // CREDIT CARD TAB
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total Amount: NPR ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),

                    // Card UI
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                              _cardNumber.isEmpty
                                  ? '**** **** **** ****'
                                  : _cardNumber,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_expiryDate.isEmpty ? 'MM/YY' : _expiryDate,
                                  style: TextStyle(color: Colors.black54)),
                              Text(
                                  _cardHolderName.isEmpty
                                      ? 'Your Name'
                                      : _cardHolderName,
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Form(
                      key: _creditFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                              _cardNumberFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: "Card Number",
                              prefixIcon: Icon(Icons.credit_card),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _cardNumber = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter card number'
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _expiryDateFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: "Expiry Date (MM/YY)",
                              prefixIcon: Icon(Icons.date_range),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _expiryDate = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter expiry date'
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _cvvController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: InputDecoration(
                              labelText: "CVV",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter CVV'
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Card Holder Name",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                setState(() => _cardHolderName = value),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter card holder name'
                                : null,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_creditFormKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PaymentSuccessPage()),
                                );
                              }
                            },
                            child: Text(
                              "Pay Now",
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.grey,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // eSEWA TAB
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _esewaFormKey,
                  child: Column(
                    children: [
                      // SizedBox(height: 20),
                      Text(
                        'Total Amount: NPR ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Image.asset(
                        'images/esewa_logo.png',
                        height: 60,
                      ),
                      SizedBox(height: 40),
                      // eSewa ID Field
                      TextFormField(
                        controller: _esewaPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'eSewa ID (Phone Number)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.length != 10 ||
                              !value.startsWith('9')) {
                            return 'Enter valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Confirmation code sent to ${_esewaPhoneController.text}")),
                            );
                          },
                          icon: Icon(Icons.send, color: Colors.green),
                          label: Text('Send Confirmation Code',
                              style: TextStyle(color: Colors.green)),
                        ),
                      ),

                      // Inside your Widget tree:
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: true,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.green,
                        autoDisposeControllers: false,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.grey.shade100,
                          inactiveFillColor: Colors.grey.shade200,
                          activeColor: Colors.green,
                          selectedColor: Colors.teal,
                          inactiveColor: Colors.grey,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onCompleted: (v) {
                          print("Code entered: $v");
                        },
                        onChanged: (value) {
                          // Store the code for validation
                          _confirmationCode = value;
                        },
                        validator: (value) {
                          if (value == null || value.length != 6) {
                            return "Enter 6-digit code";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),
                      // Spacer(),

                      // Pay with eSewa Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_esewaFormKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PaymentSuccessPage()),
                            );
                          }
                        },
                        icon: Icon(Icons.payment),
                        label: Text("Pay with eSewa"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
