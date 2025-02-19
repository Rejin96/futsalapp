import 'package:flutter/material.dart';

class Emailvalidation extends StatelessWidget {
  final TextEditingController emailController;
  final String labelText;
  const Emailvalidation(
      {super.key, required this.emailController, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: emailController,
      style: TextStyle(color: Colors.grey.shade300, fontSize: 18),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Kanit'),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email cannot be empty";
        }
        // Simple email validation
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }
}
