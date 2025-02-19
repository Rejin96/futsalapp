import 'package:flutter/material.dart';

class Forgotpass extends StatefulWidget {
  const Forgotpass({super.key});

  @override
  State<Forgotpass> createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background matching the login page
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Color(0xFF2A3D4E), // Dark green center
                    Color(0xFF3B535F), // Slightly lighter green for edges
                    Color(0xFF4C6D7A), // Light greenish tone for outer edges
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Content (forgot password form)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      // Text with border (consistent with login page)
                      Stack(
                        children: [
                          // Border text
                          Text(
                            "FUTSAL PLAYER CONNECT",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 4
                                ..color = Colors.black, // Border color
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Main text
                          Text(
                            "FUTSAL PLAYER CONNECT",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white, // Text color
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Recover your account",
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Colors.white, // Subtle text color
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      // Email Input
                      TextField(
                        controller: _emailController,
                        style: TextStyle(
                            color: Colors.grey.shade300,
                            fontFamily: 'Kanit',
                            fontSize: 18), // Consistent text color
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.white, // Consistent label color
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                            fontSize: 22, // Consistent label size
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Colors.white), // Consistent underline color
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Colors.white), // Consistent underline color
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Send verification code button (matching login button style)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFF65A3B8), // Consistent button color
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Verification code sent to your email!"),
                              backgroundColor: Colors.teal,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          "Send verification code",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Back to login page link
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Back to Login",
                          style: TextStyle(
                              color: Colors.white), // Consistent color
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
