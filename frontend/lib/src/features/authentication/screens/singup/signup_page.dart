import 'package:flutter/material.dart';
import 'package:playerconnect/src/common_widgets/Validations/emailvalidation.dart';
import 'package:playerconnect/src/common_widgets/Validations/inputvalidation.dart';
import 'package:playerconnect/src/common_widgets/Validations/passwordvalidation.dart';
import 'package:playerconnect/src/common_widgets/Validations/phonenovalidation.dart';
import '../login/login_page.dart';
import '../../../../services/csrf_services.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For making network requests
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedLocation;
  String? _selectedLocationId;

  void handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? csrfToken = prefs.getString('csrf_token');

    if (csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSRF token is missing!')),
      );
      return;
    }

    Map<String, String> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'location': _selectedLocation ?? '',
      'password': _passwordController.text,
    };

    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/signup/'),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
        'Cookie': 'csrftoken=$csrfToken',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()),
      );
    } else {
      var responseData = json.decode(response.body);
      String errorMessage = "Signup failed: ${response.statusCode}";

      if (responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

Future<void> _selectLocation() async {
  Map<String, String>? location = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFF1B2A41),
        title: Text("Select Location", style: TextStyle(color: Colors.white)),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              {"name": "Kathmandu", "id": "1"},
              {"name": "Bhaktapur", "id": "2"},
              {"name": "Lalitpur", "id": "3"}
            ]
                .map((location) => ListTile(
                      title: Text(location["name"] ?? "Unknown", style: TextStyle(color: Colors.grey.shade300)),
                      onTap: () {
                        Navigator.pop(context, location);
                      },
                    ))
                .toList(),
          ),
        ),
      );
    },
  );

  if (location != null) {
    setState(() {
      _selectedLocation = location["name"];
      _selectedLocationId = location["id"];
    });

    // Store the location ID in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_location_id', _selectedLocationId!); // Save the ID
  }
}



  @override
  void initState() {
    super.initState();
    CsrfService.fetchCsrfToken();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Color(0xFF1B2A41),
                    Color(0xFF23395B),
                    Color(0xFF2D4A69),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Text(
                            "FUTSAL PLAYER CONNECT",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "FUTSAL PLAYER CONNECT",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      Inputvalidation(
                          inputController: _nameController, labelText: "Name"),
                      SizedBox(height: 15),
                      Emailvalidation(
                          emailController: _emailController,
                          labelText: 'Email'),
                      SizedBox(height: 15),
                      Phonenovalidation(
                          phoneController: _phoneController,
                          labelText: "Phone Number"),
                      SizedBox(height: 15),
                      PasswordValidation(
                          controller: _passwordController,
                          labelText: "Password"),
                      SizedBox(height: 15),
                      PasswordValidation(
                        controller: _confirmPasswordController,
                        confirmPasswordController: _passwordController,
                        labelText: "Confirm Password",
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E3A5F),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: _selectLocation,
                        child: Text(
                          _selectedLocation ?? "Select Location",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF65A3B8),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.black,
                          elevation: 10,
                        ),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            handleSignup();
                          }
                        },
                        child: Text(
                          "SIGN UP",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Loginpage()),
                          );
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
